//
//  SessionStore.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 10.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import Combine
import Firebase
import Foundation

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
    
    @Published var inspectionsLoadingState: LoadingState<[Inspections]> = .loading
    @Published var vyplatnyedelaLoadingState: LoadingState<[Vyplatnyedela]> = .loading
    
    static let shared = SessionStore()
    
    func download(_ items: [Any], fileType: FileType, completion: @escaping (Result<URL, Error>) -> Void) {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        for item in items {
            let savedURL = documentsURL.appendingPathComponent(fileType == .photo ? "\(UUID().uuidString).jpeg" : "\(UUID().uuidString).mp4")
            URLSession.shared.downloadTask(with: fileType == .photo ? (item as! Photo).path : URL(string: "\(items.first!)")!) { fileURL, _, error in
                if let fileURL = fileURL {
                    try! FileManager.default.moveItem(at: fileURL, to: savedURL)
                    completion(.success(savedURL))
                    print(fileURL)
                    print(savedURL)
                } else if let error = error {
                    completion(.failure(error))
                }
            }.resume()
        }
    }
    
    func login(email: String, password: String, completion: @escaping (Result<LoginModel, ApiError>) -> Void) {
        let parameters = LoginParameters(
            email: email,
            password: password
        )
        
        Endpoint.api.upload(.login, parameters: parameters) { [self] (result: Result<LoginModel.NetworkResponse, ApiError>) in
            switch result {
            case let .success(value):
                loginModel = value.data
                loginParameters = LoginParameters(email: email, password: password)
                Crashlytics.crashlytics().setUserID(value.data.email)
                completion(.success(value.data))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    func logout(completion: @escaping () -> Void) {
        Endpoint.api.fetch(.logout, httpMethod: .post) { [self] (_: Result<LogoutModel, ApiError>) in
            completion()
            loginModel = nil
            loginParameters = nil
            inspectionsLoadingState = .loading
            vyplatnyedelaLoadingState = .loading
        }
    }
    
    func getInspections() {
        Endpoint.api.fetch(.inspections()) { [self] (result: Result<[Inspections], ApiError>) in
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
        Endpoint.api.fetch(.vyplatnyedela()) { [self] (result: Result<[Vyplatnyedela], ApiError>) in
            switch result {
            case let .success(value):
                if value.isEmpty {
                    vyplatnyedelaLoadingState = .empty
                } else {
                    vyplatnyedelaLoadingState = .success(value)
                }
            case let .failure(error):
                vyplatnyedelaLoadingState = .failure(error)
                log(error.localizedDescription)
            }
        }
    }
}
