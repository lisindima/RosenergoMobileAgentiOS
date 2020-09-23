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
    
    func decoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 7)
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return decoder
    }
    
    private func clearData() {
        loginModel = nil
        loginParameters = nil
        inspectionsLoadingState = .loading
        vyplatnyedelaLoadingState = .loading
        changelogLoadingState = .loading
        licenseLoadingState = .loading
    }
    
    func upload<Parameters: Encodable, T: Decodable>(_ endpoint: Endpoint, parameters: Parameters, httpMethod: String = "POST", contentType: String = "application/json", completion: @escaping (Result<T, UploadError>) -> Void) {
        var request = URLRequest(url: endpoint.url)
        request.httpMethod = httpMethod
        if let token = loginModel?.apiToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        request.httpBody = try? encoder.encode(parameters)

        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: T.self, decoder: decoder())
            .map(Result.success)
            .catch { error -> Just<Result<T, UploadError>> in
                error is DecodingError
                    ? Just(.failure(.decodeFailed(error)))
                    : Just(.failure(.uploadFailed(error)))
            }
            .receive(on: DispatchQueue.main)
            .print()
            .sink(receiveValue: completion)
            .store(in: &requests)
    }
    
    func fetch<T: Decodable>(_ endpoint: Endpoint, httpMethod: String = "GET", contentType: String = "application/json", completion: @escaping (Result<T, UploadError>) -> Void) {
        var request = URLRequest(url: endpoint.url)
        request.httpMethod = httpMethod
        if let token = loginModel?.apiToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.setValue(contentType, forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: T.self, decoder: decoder())
            .map(Result.success)
            .catch { error -> Just<Result<T, UploadError>> in
                error is DecodingError
                    ? Just(.failure(.decodeFailed(error)))
                    : Just(.failure(.uploadFailed(error)))
            }
            .receive(on: DispatchQueue.main)
            .print()
            .sink(receiveValue: completion)
            .store(in: &requests)
    }
    
    func download(_ items: [Any], fileType: FileType, completion: @escaping (Result<URL, Error>) -> Void) {
        for item in items {
            URLSession.shared.downloadTask(with: fileType == .photo ? (item as! Photo).path : URL(string: "\(items.first!)")!) { localURL, urlResponse, error in
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
        
        upload(Endpoint.login, parameters: parameters) { [self] (result: Result<LoginModel.NetworkResponse, UploadError>) in
            switch result {
            case .success(let value):
                loginModel = value.data
                loginParameters = LoginParameters(email: email, password: password)
                completion(.success(value.data))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    func logout(completion: @escaping (Bool) -> Void) {
        fetch(Endpoint.logout, httpMethod: "POST") { [self] (result: Result<LogoutModel, UploadError>) in
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
        fetch(Endpoint.inspections("")) { [self] (result: Result<[Inspections], UploadError>) in
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
        fetch(Endpoint.vyplatnyedela("")) { [self] (result: Result<[Vyplatnyedela], UploadError>) in
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
        fetch(Endpoint.changelog) { [self] (result: Result<[ChangelogModel], UploadError>) in
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
        fetch(Endpoint.license) { [self] (result: Result<[LicenseModel], UploadError>) in
            switch result {
            case .success(let value):
                licenseLoadingState = .success(value)
            case .failure(let error):
                licenseLoadingState = .failure(error)
                log(error.localizedDescription)
            }
        }
    }
}
