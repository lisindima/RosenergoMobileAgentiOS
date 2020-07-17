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
    @Published var photoParameters: [PhotoParameters] = [PhotoParameters]()
    @Published var showAlert: Bool = false
    @Published var loadingLogin: Bool = false
    @Published var logoutState: Bool = false
    @Published var uploadState: UploadState = .none
    @Published var inspectionsLoadingState: InspectionsLoadingState = .loading
    @Published var alertType: AlertType = .success
    @Published var uploadProgress: Double = 0.0
    @Published var latitude: Double = 0.0
    @Published var longitude: Double = 0.0
    
    static let shared = SessionStore()
    
    let serverURL: String = "https://rosenergo.calcn1.ru/api/"
    let yandexGeoURL: String = "https://geocode-maps.yandex.ru/1.x/"
    let apiKeyForYandexGeo: String = "deccec14-fb7f-40da-8be0-be3f7e6f2d8c"
    
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
                    if code == 401 && loginParameters != nil {
                        login(email: loginParameters!.email, password: loginParameters!.password)
                    } else if code == 401 && loginParameters == nil {
                        loginModel = nil
                    } else if code == nil {
//                        #if !os(watchOS)
//                        SPAlert.present(title: "Нет интернета!", message: "Сохраняйте осмотры на устройство.", preset: .message)
//                        #endif
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
    
    func uploadInspections(carModel: String, carRegNumber: String, carBodyNumber: String, carVin: String, insuranceContractNumber: String, carModel2: String?, carRegNumber2: String?, carBodyNumber2: String?, carVin2: String?, insuranceContractNumber2: String?, latitude: Double, longitude: Double, photoParameters: [PhotoParameters]?, localUpload: Bool, localInspections: LocalInspections?) {
        
        uploadState = .upload
        
        var localPhotoParameters: [PhotoParameters] = []
        
        if localUpload {
            for photo in localInspections!.photos! {
                localPhotoParameters.append(PhotoParameters(latitude: localInspections!.latitude, longitude: localInspections!.longitude, file: photo, maked_photo_at: localInspections!.dateInspections!))
            }
        }
        
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
            photos: (localUpload ? localPhotoParameters : photoParameters)!
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
                case .failure(let error):
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
    
    func loadAddress(latitude: Double, longitude: Double, completionHandler: @escaping (YandexGeo?, YandexGeoState) -> ()) {
        
        let parameters = YandexGeoParameters(
            apikey: apiKeyForYandexGeo,
            format: "json",
            geocode: "\(longitude), \(latitude)",
            results: "1",
            kind: "house"
        )
        
        AF.request(yandexGeoURL, method: .get, parameters: parameters)
            .validate()
            .responseDecodable(of: YandexGeo.self) { response in
                switch response.result {
                case .success:
                    guard let yandexGeoResponse = response.value else { return }
                    let yandexGeoState: YandexGeoState = .success
                    completionHandler(yandexGeoResponse, yandexGeoState)
                case .failure(let error):
                    print(error)
                    let yandexGeoState: YandexGeoState = .failure
                    completionHandler(nil, yandexGeoState)
                }
        }
    }
}

enum InspectionsLoadingState {
    case loading, failure, success
}

enum UploadState {
    case upload, none
}

enum YandexGeoState {
    case loading, failure, success
}

enum AlertMailType {
    case sent, saved, failed, error
}

enum AlertType {
    case success, error, emptyLocation, emptyPhoto, emptyTextField
}

