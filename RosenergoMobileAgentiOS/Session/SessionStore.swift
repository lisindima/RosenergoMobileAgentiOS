//
//  SessionStore.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 10.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import Combine
import SwiftUI

class SessionStore: ObservableObject {
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
    @Published var videoURL: URL? = nil
    @Published var uploadProgress: Double = 0.0
    @Published var downloadProgress: Double = 0.0
    @Published var changelogLoadingState: LoadingState<[ChangelogModel]> = .loading
    @Published var licenseLoadingState: LoadingState<[LicenseModel]> = .loading
    @Published var inspectionsLoadingState: LoadingState<[Inspections]> = .loading
    @Published var vyplatnyedelaLoadingState: LoadingState<[Vyplatnyedela]> = .loading
    
    static let shared = SessionStore()
    
    private var requests = Set<AnyCancellable>()
    
    func createRequest(_ endpoint: Endpoint, httpMethod: HTTPMethod) -> URLRequest {
        var request = URLRequest(url: endpoint.url)
        request.allowsExpensiveNetworkAccess = true
        request.httpMethod = httpMethod.rawValue
        if let token = loginModel?.apiToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("RosenergoMobileAgentiOS:\(getVersion())", forHTTPHeaderField: "User-Agent")
        return request
    }
    
    func createDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 7)
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return decoder
    }
    
    func createEncoder() -> JSONEncoder {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dataEncodingStrategy = .base64
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        return encoder
    }
    
    func upload<Parameters: Encodable, T: Decodable>(_ endpoint: Endpoint, parameters: Parameters, httpMethod: HTTPMethod = .post, completion: @escaping (Result<T, UploadError>) -> Void) {
        var request = createRequest(endpoint, httpMethod: httpMethod)
        request.httpBody = try? createEncoder().encode(parameters)
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: T.self, decoder: createDecoder())
            .map(Result.success)
            .catch { error -> Just<Result<T, UploadError>> in
                error is DecodingError ? Just(.failure(.decodeFailed(error))) : Just(.failure(.uploadFailed(error)))
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: completion)
            .store(in: &requests)
    }
    
    func fetch<T: Decodable>(_ endpoint: Endpoint, httpMethod: HTTPMethod = .get, completion: @escaping (Result<T, UploadError>) -> Void) {
        URLSession.shared.dataTaskPublisher(for: createRequest(endpoint, httpMethod: httpMethod))
            .map(\.data)
            .decode(type: T.self, decoder: createDecoder())
            .map(Result.success)
            .catch { error -> Just<Result<T, UploadError>> in
                error is DecodingError ? Just(.failure(.decodeFailed(error))) : Just(.failure(.uploadFailed(error)))
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: completion)
            .store(in: &requests)
    }
    
    func download(_ items: [Any], fileType: FileType, completion: @escaping (Result<URL, Error>) -> Void) {
        for item in items {
            URLSession.shared.downloadTask(with: fileType == .photo ? (item as! Photo).path : URL(string: "\(items.first!)")!) { localURL, _, error in
                if let localURL = localURL {
                    completion(.success(localURL))
                    print(localURL)
                } else if let error = error {
                    completion(.failure(error))
                }
            }.resume()
        }
    }
    
    func login(email: String, password: String, completion: @escaping (Result<LoginModel, Error>) -> Void) {
        let parameters = LoginParameters(
            email: email,
            password: password
        )
        
        upload(.login, parameters: parameters) { [self] (result: Result<LoginModel.NetworkResponse, UploadError>) in
            switch result {
            case let .success(value):
                loginModel = value.data
                loginParameters = LoginParameters(email: email, password: password)
                completion(.success(value.data))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    func logout(completion: @escaping (Bool) -> Void) {
        fetch(.logout, httpMethod: .post) { [self] (result: Result<LogoutModel, UploadError>) in
            switch result {
            case .success:
                completion(true)
                clearData()
            case let .failure(error):
                completion(true)
                clearData()
                log(error.localizedDescription)
            }
        }
    }
    
    func getInspections() {
        fetch(.inspections("")) { [self] (result: Result<[Inspections], UploadError>) in
            switch result {
            case let .success(value):
                if value.isEmpty {
                    inspectionsLoadingState = .empty
                } else {
                    inspectionsLoadingState = .success(value)
                }
            case let .failure(error):
                inspectionsLoadingState = .failure(error)
                log(error.localizedDescription)
            }
        }
    }
    
    func getVyplatnyedela() {
        fetch(.vyplatnyedela("")) { [self] (result: Result<[Vyplatnyedela], UploadError>) in
            switch result {
            case let .success(value):
                if value.isEmpty {
                    vyplatnyedelaLoadingState = .empty
                } else {
                    vyplatnyedelaLoadingState = .success(value)
                }
            case let .failure(error):
                vyplatnyedelaLoadingState = .failure(error)
                debugPrint(error)
            }
        }
    }
    
    func getChangelog() {
        fetch(.changelog) { [self] (result: Result<[ChangelogModel], UploadError>) in
            switch result {
            case let .success(value):
                changelogLoadingState = .success(value)
            case let .failure(error):
                changelogLoadingState = .failure(error)
                log(error.localizedDescription)
            }
        }
    }
    
    func getLicense() {
        fetch(.license) { [self] (result: Result<[LicenseModel], UploadError>) in
            switch result {
            case let .success(value):
                licenseLoadingState = .success(value)
            case let .failure(error):
                licenseLoadingState = .failure(error)
                log(error.localizedDescription)
            }
        }
    }
    
    private func clearData() {
        loginModel = nil
        loginParameters = nil
        inspectionsLoadingState = .loading
        vyplatnyedelaLoadingState = .loading
        changelogLoadingState = .loading
        licenseLoadingState = .loading
    }
}
