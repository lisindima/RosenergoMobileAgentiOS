//
//  SessionStore.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 10.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import Alamofire
import Combine
import SwiftUI

class SessionStore: ObservableObject, RequestInterceptor {
    @CodableUserDefaults(key: "loginModel", default: nil)
    var loginModel: LoginModel? {
        willSet {
            objectWillChange.send()
        }
    }
    
    @CodableUserDefaults(key: "loginParameters", default: nil)
    var loginParameters: LoginParameters? {
        willSet {
            objectWillChange.send()
        }
    }
    
    @Published var photosURL = [URL]()
    @Published var videoURL: URL?
    @Published var uploadProgress: Double = 0.0
    @Published var downloadProgress: Double = 0.0
    @Published var changelogLoadingFailure: Bool = false
    @Published var licenseLoadingFailure: Bool = false
    @Published var inspectionsLoadingState: LoadingState = .loading
    @Published var vyplatnyedelaLoadingState: LoadingState = .loading
    @Published var inspections = [Inspections]()
    @Published var vyplatnyedela = [Vyplatnyedela]()
    @Published var сhangelogModel = [ChangelogModel]()
    @Published var licenseModel = [LicenseModel]()
    
    static let shared = SessionStore()
    
    var cancellation: AnyCancellable?
    
    let serverURL: String = "https://rosenergo.calcn1.ru/api/"
    
    private func clearData() {
        loginModel = nil
        loginParameters = nil
        inspections.removeAll()
        inspectionsLoadingState = .loading
        vyplatnyedela.removeAll()
        vyplatnyedelaLoadingState = .loading
    }
    
    func adapt(_ urlRequest: URLRequest, for _: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        urlRequest.headers.add(.authorization(bearerToken: loginModel!.data.apiToken))
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for _: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 else {
            return completion(.doNotRetryWithError(error))
        }
        
        login(email: loginParameters!.email, password: loginParameters!.password) { [self] result in
            switch result {
            case let .success(response):
                loginModel = response
                completion(.retry)
            case .failure:
                completion(.doNotRetryWithError(error))
            }
        }
    }
    
    func login(email: String, password: String, completion: @escaping (Result<LoginModel, Error>) -> Void) {
        let parameters = LoginParameters(
            email: email,
            password: password
        )
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        AF.request(serverURL + "login", method: .post, parameters: parameters)
            .validate()
            .responseDecodable(of: LoginModel.self, decoder: decoder) { response in
                switch response.result {
                case .success:
                    guard let response = response.value else { return }
                    completion(.success(response))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }
    
    func logout(completion: @escaping (Bool) -> Void) {
        let headers: HTTPHeaders = [
            .authorization(bearerToken: loginModel?.data.apiToken ?? ""),
            .accept("application/json"),
        ]
        
        AF.request(serverURL + "logout", method: .post, headers: headers, interceptor: SessionStore.shared)
            .validate()
            .response { [self] _ in
                completion(true)
                clearData()
            }
    }
    
    func upload<Parameters: Encodable>(_ url: String, parameters: Parameters? = nil, completion: @escaping (Result<Bool, Error>) -> Void) {
        let headers: HTTPHeaders = [
            .authorization(bearerToken: loginModel?.data.apiToken ?? ""),
            .accept("application/json"),
        ]
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        AF.request(serverURL + url, method: .post, parameters: parameters, encoder: JSONParameterEncoder(encoder: encoder), headers: headers, interceptor: SessionStore.shared)
            .validate()
            .uploadProgress { [self] progress in
                uploadProgress = progress.fractionCompleted
            }
            .response { response in
                switch response.result {
                case .success:
                    completion(.success(true))
                case let .failure(error):
                    completion(.failure(error))
                    log(error)
                }
            }
    }
    
    func request<T: Codable>(_ url: String, method: HTTPMethod = .get, headers: HTTPHeaders? = nil) -> AnyPublisher<Result<T, AFError>, Never> {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 7)
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        let publisher = AF.request(url, method: method, headers: headers, interceptor: SessionStore.shared)
            .validate()
            .uploadProgress { [self] progress in
                uploadProgress = progress.fractionCompleted
            }
            .publishDecodable(type: T.self, decoder: decoder)
        return publisher.result()
    }
    
    func load<T: Codable>(_ url: String, completion: @escaping (Result<T, Error>) -> Void) {
        let headers: HTTPHeaders = [
            .authorization(bearerToken: loginModel?.data.apiToken ?? ""),
            .accept("application/json"),
        ]
        
        cancellation = request(serverURL + url, headers: headers)
            .sink { (response: Result<T, AFError>) in
                switch response {
                case let .success(value):
                    completion(.success(value))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }
    
    func getVyplatnyedela() {
        load("vyplatnyedelas") { [self] (response: Result<[Vyplatnyedela], Error>) in
            switch response {
            case let .success(value):
                vyplatnyedela = value
                vyplatnyedelaLoadingState = .success
            case let .failure(error):
                vyplatnyedelaLoadingState = .failure
                log(error)
            }
        }
    }
    
    func getInspections() {
        load("inspections") { [self] (response: Result<[Inspections], Error>) in
            switch response {
            case let .success(value):
                inspections = value
                inspectionsLoadingState = .success
            case let .failure(error):
                inspectionsLoadingState = .failure
                log(error)
            }
        }
    }
    
    func download(_ items: [Any], fileType: FileType, completion: @escaping (Result<URL, Error>) -> Void) {
        for item in items {
            let destination: DownloadRequest.Destination = { _, _ in
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let fileURL = documentsURL.appendingPathComponent(fileType == .photo ? "\((item as! Photo).id).jpeg" : "video.mp4")
                
                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
            }
            
            AF.download(fileType == .photo ? (item as! Photo).path : "\(items.first!)", to: destination)
                .validate()
                .downloadProgress { [self] progress in
                    downloadProgress = progress.fractionCompleted
                }
                .response { response in
                    switch response.result {
                    case .success:
                        guard let fileURL = response.value else { return }
                        completion(.success(fileURL!))
                    case let .failure(error):
                        completion(.failure(error))
                    }
                }
        }
    }
    
    func loadLicense() {
        cancellation = request("https://api.lisindmitriy.me/license")
            .sink { [self] (response: Result<[LicenseModel], AFError>) in
                switch response {
                case let .success(value):
                    licenseModel = value
                case let .failure(error):
                    licenseLoadingFailure = true
                    log(error)
                }
            }
    }
    
    func loadChangelog() {
        cancellation = request("https://api.lisindmitriy.me/changelog")
            .sink { [self] (response: Result<[ChangelogModel], AFError>) in
                switch response {
                case let .success(value):
                    сhangelogModel = value
                case let .failure(error):
                    changelogLoadingFailure = true
                    log(error)
                }
            }
    }
}
