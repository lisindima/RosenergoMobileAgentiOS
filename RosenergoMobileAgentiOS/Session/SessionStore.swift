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
    @Published var alertError: AlertError?
    @Published var showServerAlert: Bool = false
    @Published var loginState: Bool = false
    @Published var logoutState: Bool = false
    @Published var uploadState: Bool = false
    @Published var inspectionsLoadingState: LoadingState = .loading
    @Published var vyplatnyedelaLoadingState: LoadingState = .loading
    @Published var uploadProgress: Double = 0.0
    @Published var isOpenUrlId: String?
    @Published var сhangelogModel: [ChangelogModel] = [ChangelogModel]()
    @Published var changelogLoadingFailure: Bool = false
    @Published var licenseModel: [LicenseModel] = [LicenseModel]()
    @Published var licenseLoadingFailure: Bool = false
    
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
        
        loginState = true
        
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
                    loginState = false
                case .failure(let error):
                    showAlert = true
                    loginState = false
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
        
        uploadState = true
        
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
                    alertError = AlertError(title: "Успешно", message: "Осмотр успешно загружен на сервер.", action: true)
                    uploadState = false
                case .failure(let error):
                    alertError = AlertError(title: "Ошибка", message: "Попробуйте загрузить осмотр позже.\n\(error.errorDescription ?? "")", action: false)
                    uploadState = false
                    debugPrint(error)
                }
            }
    }
    
    func uploadVyplatnyeDela(parameters: VyplatnyeDelaParameters) {
        
        uploadState = true
        
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
                    alertError = AlertError(title: "Успешно", message: "Выплатное дело успешно загружено на сервер.", action: true)
                    uploadState = false
                case .failure(let error):
                    alertError = AlertError(title: "Ошибка", message: "Попробуйте загрузить выплатное дело позже.\n\(error.errorDescription ?? "")", action: false)
                    uploadState = false
                    print(error.errorDescription!)
                }
            }
    }
    
    func loadChangelog() {
        AF.request("https://api.lisindmitriy.me/changelog")
            .validate()
            .responseDecodable(of: [ChangelogModel].self) { [self] response in
                switch response.result {
                case .success:
                    guard let сhangelog = response.value else { return }
                    сhangelogModel = сhangelog
                case .failure(let error):
                    changelogLoadingFailure = true
                    print("Список изменений не загружен: \(error.errorDescription!)")
                }
            }
    }
    
    func loadLicense() {
        AF.request("https://api.lisindmitriy.me/license")
            .validate()
            .responseDecodable(of: [LicenseModel].self) { [self] response in
                switch response.result {
                case .success:
                    guard let license = response.value else { return }
                    licenseModel = license
                case .failure(let error):
                    licenseLoadingFailure = true
                    print("Список лицензий не загружен: \(error.errorDescription!)")
                }
            }
    }
}

enum LoadingState {
    case loading, failure, success
}
