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

    @Published var photosData = [Data]()
    @Published var videoURL: String?
    @Published var alertItem: AlertItem?
    @Published var uploadProgress: Double = 0.0
    @Published var uploadState: Bool = false
    @Published var changelogLoadingFailure: Bool = false
    @Published var licenseLoadingFailure: Bool = false
    @Published var inspectionsLoadingState: LoadingState = .loading
    @Published var vyplatnyedelaLoadingState: LoadingState = .loading
    @Published var inspections = [Inspections]()
    @Published var vyplatnyedela = [Vyplatnyedela]()
    @Published var сhangelogModel = [ChangelogModel]()
    @Published var licenseModel = [LicenseModel]()

    static let shared = SessionStore()

    let serverURL: String = "https://rosenergo.calcn1.ru/api/"

    func stringDate() -> String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let createStringDate = dateFormatter.string(from: currentDate)
        return createStringDate
    }

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

        AF.request(serverURL + "login", method: .post, parameters: parameters)
            .validate()
            .responseDecodable(of: LoginModel.self) { response in
                switch response.result {
                case .success:
                    guard let response = response.value else { return }
                    completion(.success(response))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    func logout(completion: @escaping (_ result: Bool) -> Void) {
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

    func uploadInspections(parameters: InspectionParameters) {
        uploadState = true

        let headers: HTTPHeaders = [
            .authorization(bearerToken: loginModel?.data.apiToken ?? ""),
            .accept("application/json"),
        ]

        AF.request(serverURL + "testinspection", method: .post, parameters: parameters, encoder: JSONParameterEncoder.default, headers: headers, interceptor: SessionStore.shared)
            .validate()
            .uploadProgress { [self] progress in
                uploadProgress = progress.fractionCompleted
            }
            .response { [self] response in
                switch response.result {
                case .success:
                    alertItem = AlertItem(title: "Успешно", message: "Осмотр успешно загружен на сервер.", action: true)
                    uploadState = false
                case let .failure(error):
                    alertItem = AlertItem(title: "Ошибка", message: "Попробуйте загрузить осмотр позже.\n\(error.errorDescription ?? "")", action: false)
                    uploadState = false
                    debugPrint(error)
                }
            }
    }

    func uploadVyplatnyeDela(parameters: VyplatnyeDelaParameters) {
        uploadState = true

        let headers: HTTPHeaders = [
            .authorization(bearerToken: loginModel?.data.apiToken ?? ""),
            .accept("application/json"),
        ]

        AF.request(serverURL + "vyplatnyedela", method: .post, parameters: parameters, encoder: JSONParameterEncoder.default, headers: headers, interceptor: SessionStore.shared)
            .validate()
            .uploadProgress { [self] progress in
                uploadProgress = progress.fractionCompleted
            }
            .response { [self] response in
                switch response.result {
                case .success:
                    alertItem = AlertItem(title: "Успешно", message: "Выплатное дело успешно загружено на сервер.", action: true)
                    uploadState = false
                case let .failure(error):
                    alertItem = AlertItem(title: "Ошибка", message: "Попробуйте загрузить выплатное дело позже.\n\(error.errorDescription ?? "")", action: false)
                    uploadState = false
                    print(error.errorDescription!)
                }
            }
    }

    var cancellation: AnyCancellable?

    func request<T: Codable>(_ url: String, method: HTTPMethod = .get, headers: HTTPHeaders? = nil) -> AnyPublisher<Result<T, AFError>, Never> {
        let publisher = AF.request(url, method: method, headers: headers, interceptor: SessionStore.shared)
            .validate()
            .uploadProgress { [self] progress in
                uploadProgress = progress.fractionCompleted
            }
            .publishDecodable(type: T.self)
        return publisher.result()
    }

    func getVyplatnyedela() {
        let headers: HTTPHeaders = [
            .authorization(bearerToken: loginModel?.data.apiToken ?? ""),
            .accept("application/json"),
        ]

        cancellation = request(serverURL + "vyplatnyedelas", headers: headers)
            .sink { [self] (response: Result<[Vyplatnyedela], AFError>) in
                switch response {
                case let .success(value):
                    vyplatnyedela = value
                    vyplatnyedelaLoadingState = .success
                case let .failure(error):
                    vyplatnyedelaLoadingState = .failure
                    print(error)
                }
            }
    }

    func getInspections() {
        let headers: HTTPHeaders = [
            .authorization(bearerToken: loginModel?.data.apiToken ?? ""),
            .accept("application/json"),
        ]

        cancellation = request(serverURL + "inspections", headers: headers)
            .sink { [self] (response: Result<[Inspections], AFError>) in
                switch response {
                case let .success(value):
                    inspections = value
                    inspectionsLoadingState = .success
                case let .failure(error):
                    inspectionsLoadingState = .failure
                    print(error)
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
                    print(error)
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
                    print(error)
                }
            }
    }
    
    func downloadPhoto(_ photos: [Photo], completion: @escaping (Result<URL, Error>) -> Void) {
        for photo in photos {
            let destination: DownloadRequest.Destination = { _, _ in
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileURL = documentsURL.appendingPathComponent("\(photo.id).jpeg")

                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
            }
            
            AF.download(photo.path, to: destination)
                .response { response in
                    switch response.result {
                    case .success:
                        guard let photoURL = response.value else { return }
                        completion(.success(photoURL!))
                    case let .failure(error):
                        print(error)
                    }
                }
        }
    }
    
    func downloadVideo(_ url: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let destination: DownloadRequest.Destination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("video.mp4")

            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        AF.download(url, to: destination)
            .downloadProgress { progress in
                print("Download Progress: \(progress.fractionCompleted)")
            }
            .response { response in
                switch response.result {
                case .success:
                    guard let videoURL = response.value else { return }
                    print(videoURL!)
                    completion(.success(videoURL!))
                case let .failure(error):
                    print(error)
                }
            }
    }
}

enum LoadingState {
    case loading, failure, success
}
