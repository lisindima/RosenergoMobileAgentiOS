//
//  SessionStore.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 10.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import Combine
import Alamofire

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
    
    @Published var inspections: [Inspections] = [Inspections]()
    @Published var vyplatnyedela: [Vyplatnyedela] = [Vyplatnyedela]()
    @Published var photosData: [Data] = [Data]()
    @Published var videoURL: String?
    @Published var showAlert: Bool = false
    @Published var showServerAlert: Bool = false
    @Published var loadingLogin: Bool = false
    @Published var logoutState: Bool = false
    @Published var uploadState: UploadState = .none
    @Published var inspectionsLoadingState: LoadingState = .loading
    @Published var vyplatnyedelaLoadingState: LoadingState = .loading
    @Published var alertType: AlertType = .success
    @Published var alertError: String?
    @Published var uploadProgress: Double = 0.0
    @Published var isOpenUrlId: String? 
    
    static let shared = SessionStore()
    
    let serverURL: String = "https://rosenergo.calcn1.ru/api/"
    
    func stringDate() -> String {
        let currentDate: Date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let createStringDate = dateFormatter.string(from: currentDate)
        return createStringDate
    }
    
    func login(email: String, password: String) {
        
        loadingLogin = true
        
        let parameters = LoginParameters(
            email: email,
            password: password
        )
        
        AF.request(serverURL + "login", method: .post, parameters: parameters, encoder: JSONParameterEncoder.default)
            .validate()
            .responseDecodable(of: LoginModel.self) { [self] response in
                switch response.result {
                case .success:
                    guard let loginModelResponse = response.value else { return }
                    loginModel = loginModelResponse
                    loginParameters = parameters
                    loadingLogin = false
                case .failure(let error):
                    showAlert = true
                    loadingLogin = false
                    print(error)
                }
        }
    }
    
    func logout() {
        
        logoutState = true
        
        let headers: HTTPHeaders = [
            .authorization(bearerToken: loginModel?.data.apiToken ?? ""),
            .accept("application/json")
        ]
        
        AF.request(serverURL + "logout", method: .post, headers: headers)
            .validate()
            .responseJSON { [self] response in
                switch response.result {
                case .success:
                    loginModel = nil
                    logoutState = false
                    loginParameters = nil
                    inspections.removeAll()
                    inspectionsLoadingState = .loading
                case .failure(let error):
                    loginModel = nil
                    logoutState = false
                    loginParameters = nil
                    inspections.removeAll()
                    inspectionsLoadingState = .loading
                    print(error.errorDescription!)
                }
        }
    }
    
    func validateToken() {
        
        let headers: HTTPHeaders = [
            .authorization(bearerToken: loginModel?.data.apiToken ?? ""),
            .accept("application/json")
        ]
        
        AF.request(serverURL + "token", method: .post, headers: headers)
            .validate()
            .responseJSON { [self] response in
                switch response.result {
                case .success:
                    break
                case .failure:
                    if let code = response.response?.statusCode {
                        if code != 200, loginParameters != nil {
                            login(email: loginParameters!.email, password: loginParameters!.password)
                        } else if code != 200, loginParameters == nil {
                            loginModel = nil
                        } else {
                            break
                        }
                    } else {
                        showServerAlert = true
                    }
                }
            }
    }
    
    func getInspections() {
        
        let headers: HTTPHeaders = [
            .authorization(bearerToken: loginModel?.data.apiToken ?? ""),
            .accept("application/json")
        ]
        
        AF.request(serverURL + "inspections", method: .get, headers: headers)
            .validate()
            .responseDecodable(of: [Inspections].self) { [self] response in
                switch response.result {
                case .success:
                    guard let inspectionsResponse = response.value else { return }
                    inspections = inspectionsResponse
                    inspectionsLoadingState = .success
                case .failure(let error):
                    inspectionsLoadingState = .failure
                    print(error.errorDescription!)
                }
        }
    }
    
    func getVyplatnyedela() {
        
        let headers: HTTPHeaders = [
            .authorization(bearerToken: loginModel?.data.apiToken ?? ""),
            .accept("application/json")
        ]
        
        AF.request(serverURL + "vyplatnyedelas", method: .get, headers: headers)
            .validate()
            .responseDecodable(of: [Vyplatnyedela].self) { [self] response in
                switch response.result {
                case .success:
                    guard let vyplatnyedelaResponse = response.value else { return }
                    vyplatnyedela = vyplatnyedelaResponse
                    vyplatnyedelaLoadingState = .success
                case .failure(let error):
                    vyplatnyedelaLoadingState = .failure
                    print(error.errorDescription!)
                }
        }
    }
    
    func uploadInspections(parameters: InspectionParameters) {
        
        uploadState = .upload
        
        let headers: HTTPHeaders = [
            .authorization(bearerToken: loginModel?.data.apiToken ?? ""),
            .accept("application/json")
        ]
        
        AF.request(serverURL + "testinspection", method: .post, parameters: parameters, encoder: JSONParameterEncoder.default, headers: headers)
            .validate()
            .uploadProgress { [self] progress in
                uploadProgress = progress.fractionCompleted
            }
            .response { [self] response in
                switch response.result {
                case .success:
                    alertType = .success
                    uploadState = .none
                    showAlert = true
                case .failure(let error):
                    alertError = error.errorDescription
                    alertType = .error
                    uploadState = .none
                    showAlert = true
                    debugPrint(error)
            }
        }
    }
    
    func uploadVyplatnyeDela(parameters: VyplatnyeDelaParameters) {
        
        uploadState = .upload
        
        let headers: HTTPHeaders = [
            .authorization(bearerToken: loginModel?.data.apiToken ?? ""),
            .accept("application/json")
        ]
        
        AF.request(serverURL + "vyplatnyedela", method: .post, parameters: parameters, encoder: JSONParameterEncoder.default, headers: headers)
            .validate()
            .uploadProgress { [self] progress in
                uploadProgress = progress.fractionCompleted
            }
            .response { [self] response in
                switch response.result {
                case .success:
                    alertType = .success
                    uploadState = .none
                    showAlert = true
                case .failure(let error):
                    alertError = error.errorDescription
                    alertType = .error
                    uploadState = .none
                    showAlert = true
                    print(error.errorDescription!)
            }
        }
    }
}

enum LoadingState {
    case loading, failure, success
}

enum UploadState {
    case upload, none
}

enum AlertMailType {
    case sent, saved, failed, error
}

enum AlertType {
    case success, error, emptyLocation, emptyPhoto, emptyTextField
}

