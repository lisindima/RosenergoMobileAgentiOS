//
//  SessionStore.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 10.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import Alamofire
import Combine
import Defaults
import SwiftUI

class SessionStore: ObservableObject {
    @Default(.loginModel) var loginModel {
        willSet {
            objectWillChange.send()
        }
    }
    
    @Default(.loginParameters) var loginParameters {
        willSet {
            objectWillChange.send()
        }
    }
    
    @Published var inspections = [Inspections]()
    @Published var vyplatnyedela = [Vyplatnyedela]()
    @Published var photoParameters = [PhotoParameters]()
    @Published var loadingLogin: Bool = false
    @Published var uploadState: UploadState = .none
    @Published var inspectionsLoadingState: LoadingState = .loading
    @Published var vyplatnyedelaLoadingState: LoadingState = .loading
    @Published var alertType: AlertType = .success
    @Published var uploadProgress: Double = 0.0
    @Published var showAlert: Bool = false
    @Published var showServerAlert: Bool = false
    @Published var openListInspections: Bool = false
    @Published var openCreateInspections: Bool = false
    @Published var openCreateVyplatnyeDela: Bool = false
    @Published var errorAlert: String?
    
    static let shared = SessionStore()
    
    let serverURL: String = "https://rosenergo.calcn1.ru/api/"
    let yandexGeoURL: String = "https://geocode-maps.yandex.ru/1.x/"
    let apiKeyForYandexGeo: String = "deccec14-fb7f-40da-8be0-be3f7e6f2d8c"
    
    func stringDate() -> String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let createStringDate = dateFormatter.string(from: currentDate)
        return createStringDate
    }
    
    func updateLocation(latitude: Double, longitude: Double) {
        let headers: HTTPHeaders = [
            .authorization(bearerToken: loginModel?.data.apiToken ?? ""),
            .accept("application/json"),
        ]
        
        let parameters = LocationAgentUpdate(
            latitude: latitude,
            longitude: longitude
        )
        
        if let agent = loginModel?.data.agentID {
            AF.request(serverURL + "updateLocation/\(agent)", method: .post, parameters: parameters, headers: headers)
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case let .success(value):
                        print("Геолокация обновлена\n\(value)")
                    case let .failure(error):
                        print("Геолокация НЕОБНОВЛЕНА\n\(error)")
                    }
                }
        } else {
            print("Нет токена")
        }
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
                case let .failure(error):
                    showAlert = true
                    loadingLogin = false
                    print(error)
                }
        }
    }
    
    func logout() {
        let headers: HTTPHeaders = [
            .authorization(bearerToken: loginModel?.data.apiToken ?? ""),
            .accept("application/json"),
        ]
        
        AF.request(serverURL + "logout", method: .post, headers: headers)
            .validate()
            .responseJSON { [self] response in
                switch response.result {
                case .success:
                    loginModel = nil
                    loginParameters = nil
                    inspections.removeAll()
                    inspectionsLoadingState = .loading
                case let .failure(error):
                    loginModel = nil
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
            .accept("application/json"),
        ]
        
        AF.request(serverURL + "token", method: .post, headers: headers)
            .validate()
            .responseJSON { [self] response in
                let code = response.response?.statusCode
                switch response.result {
                case .success:
                    break
                case .failure:
                    if code == 401, loginParameters != nil {
                        login(email: loginParameters!.email, password: loginParameters!.password)
                    } else if code == 401, loginParameters == nil {
                        loginModel = nil
                    } else if code == nil {
                        showServerAlert = true
                    } else {
                        break
                    }
                }
        }
    }
    
    func getInspections() {
        let headers: HTTPHeaders = [
            .authorization(bearerToken: loginModel?.data.apiToken ?? ""),
            .accept("application/json"),
        ]
        
        AF.request(serverURL + "inspections", method: .get, headers: headers)
            .validate()
            .responseDecodable(of: [Inspections].self) { [self] response in
                switch response.result {
                case .success:
                    guard let inspectionsResponse = response.value else { return }
                    inspections = inspectionsResponse
                    inspectionsLoadingState = .success
                case let .failure(error):
                    inspectionsLoadingState = .failure
                    print(error.errorDescription!)
                }
        }
    }
    
    func getVyplatnyedela() {
        let headers: HTTPHeaders = [
            .authorization(bearerToken: loginModel?.data.apiToken ?? ""),
            .accept("application/json"),
        ]

        AF.request(serverURL + "vyplatnyedelas", method: .get, headers: headers)
            .validate()
            .responseDecodable(of: [Vyplatnyedela].self) { [self] response in
                switch response.result {
                case .success:
                    guard let vyplatnyedelaResponse = response.value else { return }
                    vyplatnyedela = vyplatnyedelaResponse
                    vyplatnyedelaLoadingState = .success
                case let .failure(error):
                    vyplatnyedelaLoadingState = .failure
                    print(error.errorDescription!)
                }
        }
    }
    
    func uploadInspections(carModel: String, carRegNumber: String, carBodyNumber: String, carVin: String, insuranceContractNumber: String, carModel2: String?, carRegNumber2: String?, carBodyNumber2: String?, carVin2: String?, insuranceContractNumber2: String?, latitude: Double, longitude: Double, photoParameters: [PhotoParameters]) {
        uploadState = .upload
        
        let headers: HTTPHeaders = [
            .authorization(bearerToken: loginModel?.data.apiToken ?? ""),
            .accept("application/json"),
        ]
        
        let parameters = InspectionParameters(
            car_model: carModel,
            car_reg_number: carRegNumber,
            car_body_number: carBodyNumber,
            car_vin: carVin,
            insurance_contract_number: insuranceContractNumber,
            car_model2: carModel2,
            car_reg_number2: carRegNumber2,
            car_body_number2: carBodyNumber2,
            car_vin2: carVin2,
            insurance_contract_number2: insuranceContractNumber2,
            latitude: latitude,
            longitude: longitude,
            photos: photoParameters
        )
        
        AF.request(serverURL + "inspection", method: .post, parameters: parameters, encoder: JSONParameterEncoder.default, headers: headers)
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
                case let .failure(error):
                    errorAlert = error.errorDescription
                    alertType = .error
                    uploadState = .none
                    showAlert = true
                    print(error.errorDescription!)
            }
        }
    }
    
    func uploadVyplatnyeDela(insuranceContractNumber: String, numberZayavlenia: String, latitude: Double, longitude: Double, photos: [PhotoParameters]) {
        uploadState = .upload
        
        let headers: HTTPHeaders = [
            .authorization(bearerToken: loginModel?.data.apiToken ?? ""),
            .accept("application/json"),
        ]
        
        let parameters = VyplatnyeDelaParameters(
            insurance_contract_number: insuranceContractNumber,
            number_zayavlenia: numberZayavlenia,
            latitude: latitude,
            longitude: longitude,
            photos: photos
        )
        
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
                case let .failure(error):
                    errorAlert = error.errorDescription
                    alertType = .error
                    uploadState = .none
                    showAlert = true
                    print(error.errorDescription!)
                }
        }
    }
}

extension Defaults.Keys {
    static let loginModel = Key<LoginModel?>("loginModel", default: nil)
    static let loginParameters = Key<LoginParameters?>("loginParameters", default: nil)
}

enum LoadingState {
    case loading, failure, success
}

enum UploadState {
    case upload, none
}

enum YandexGeoState {
    case loading, failure, success
}

enum AlertType {
    case success, error, emptyLocation, emptyPhoto, emptyTextField
}
