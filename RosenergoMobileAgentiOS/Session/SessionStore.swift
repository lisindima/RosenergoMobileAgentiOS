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
                let code = response.response?.statusCode
                switch response.result {
                case .success:
                    break
                case .failure:
                    if code == 500 && loginParameters != nil {
                        login(email: loginParameters!.email, password: loginParameters!.password)
                    } else if code == 500 && loginParameters == nil {
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
    
    func uploadInspections(carModel: String, carRegNumber: String, carBodyNumber: String, carVin: String, insuranceContractNumber: String, carModel2: String?, carRegNumber2: String?, carBodyNumber2: String?, carVin2: String?, insuranceContractNumber2: String?, latitude: Double, longitude: Double, photoParameters: [PhotoParameters], video: Data?) {
        
        uploadState = .upload
        
        let headers: HTTPHeaders = [
            .authorization(bearerToken: loginModel?.data.apiToken ?? ""),
            .accept("application/json")
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
            photos: photoParameters,
            video: video
        )
        
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
                    alertType = .error
                    uploadState = .none
                    showAlert = true
                    debugPrint(error)
            }
        }
    }
    
    func uploadVyplatnyeDela(insuranceContractNumber: String, numberZayavlenia: String, latitude: Double, longitude: Double, photos: [PhotoParameters]) {
        
        uploadState = .upload
        
        let headers: HTTPHeaders = [
            .authorization(bearerToken: loginModel?.data.apiToken ?? ""),
            .accept("application/json")
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
                case .failure(let error):
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

