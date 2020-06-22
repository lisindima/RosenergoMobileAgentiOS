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
import Defaults
#if !os(watchOS)
import CoreLocation
import SPAlert
import FirebaseCrashlytics
#endif

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
    
    @Published var inspections: [Inspections] = [Inspections]()
    @Published var photoParameters: [PhotoParameters] = [PhotoParameters]()
    @Published var loadingLogin: Bool = false
    @Published var uploadState: UploadState = .none
    @Published var inspectionsLoadingState: InspectionsLoadingState = .loading
    @Published var uploadProgress: Double = 0.0
    @Published var latitude: Double = 0.0
    @Published var longitude: Double = 0.0
    @Published var openListInspections: Bool = false
    @Published var openCreateInspections: Bool = false
    @Published var openCreateVyplatnyeDela: Bool = false
    
    static let shared = SessionStore()
    
    let serverURL: String = "https://rosenergo.calcn1.ru/api/"
    let yandexGeoURL: String = "https://geocode-maps.yandex.ru/1.x/"
    let apiKeyForYandexGeo: String = "deccec14-fb7f-40da-8be0-be3f7e6f2d8c"
    
    let stringDate: String = {
        var currentDate: Date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let createStringDate = dateFormatter.string(from: currentDate)
        return createStringDate
    }()
    
    var locationManager = CLLocationManager()
    
    #if !os(watchOS)
    func getLocation() {
        locationManager.requestWhenInUseAuthorization()
        var currentLoc: CLLocation!
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == .authorizedAlways {
            currentLoc = locationManager.location
            latitude = currentLoc.coordinate.latitude
            longitude = currentLoc.coordinate.longitude
        } else {
            latitude = 0.0
            longitude = 0.0
        }
    }
    #endif
    
    func login(email: String, password: String) {
        
        loadingLogin = true
        
        let parameters = LoginParameters(
            email: email,
            password: password
        )
        
        AF.request(serverURL + "login", method: .post, parameters: parameters, encoder: JSONParameterEncoder.default)
            .validate()
            .responseDecodable(of: LoginModel.self) { response in
                switch response.result {
                case .success:
                    guard let loginModel = response.value else { return }
                    self.loginModel = loginModel
                    self.loginParameters = parameters
                    self.loadingLogin = false
                    #if !os(watchOS)
                    Crashlytics.crashlytics().setUserID(self.loginModel!.data.email)
                    #endif
                case .failure(let error):
                    #if !os(watchOS)
                    SPAlert.present(title: "Ошибка!", message: "Неправильный логин или пароль.", preset: .error)
                    #endif
                    print(error)
                    self.loadingLogin = false
                }
        }
    }
    
    func logout() {
        
        let headers: HTTPHeaders = [
            .authorization(bearerToken: loginModel!.data.apiToken),
            .accept("application/json")
        ]
        
        AF.request(serverURL + "logout", method: .post, headers: headers)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success:
                    self.loginModel = nil
                    self.loginParameters = nil
                    self.inspections.removeAll()
                    self.inspectionsLoadingState = .loading
                    #if !os(watchOS)
                    Crashlytics.crashlytics().setUserID("")
                    #endif
                case .failure(let error):
                    self.loginModel = nil
                    self.loginParameters = nil
                    self.inspections.removeAll()
                    self.inspectionsLoadingState = .loading
                    #if !os(watchOS)
                    Crashlytics.crashlytics().setUserID("")
                    #endif
                    print(error.errorDescription!)
                }
        }
    }
    
    func validateToken() {
        
        let headers: HTTPHeaders = [
            .authorization(bearerToken: loginModel!.data.apiToken),
            .accept("application/json")
        ]
        
        AF.request(serverURL + "token", method: .post, headers: headers)
            .validate()
            .responseJSON { response in
                let code = response.response?.statusCode
                switch response.result {
                case .success:
                    break
                case .failure:
                    if code == 401 && self.loginParameters != nil {
                        self.login(email: self.loginParameters!.email, password: self.loginParameters!.password)
                    } else if code == 401 && self.loginParameters == nil {
                        self.loginModel = nil
                    } else if code == nil {
                        #if !os(watchOS)
                        SPAlert.present(title: "Нет интернета!", message: "Сохраняйте осмотры на устройство.", preset: .message)
                        #endif
                    } else {
                        break
                    }
                }
        }
    }
    
    func getInspections() {
        
        let headers: HTTPHeaders = [
            .authorization(bearerToken: loginModel!.data.apiToken),
            .accept("application/json")
        ]
        
        AF.request(serverURL + "inspections", method: .get, headers: headers)
            .validate()
            .responseDecodable(of: [Inspections].self) { response in
                switch response.result {
                case .success:
                    guard let inspections = response.value else { return }
                    self.inspections = inspections
                    self.inspectionsLoadingState = .success
                case .failure(let error):
                    self.inspectionsLoadingState = .failure
                    print(error.errorDescription!)
                }
        }
    }
    
    func uploadInspections(carModel: String, carRegNumber: String, carBodyNumber: String, carVin: String, insuranceContractNumber: String, carModel2: String?, carRegNumber2: String?, carBodyNumber2: String?, carVin2: String?, insuranceContractNumber2: String?, latitude: Double, longitude: Double, photoParameters: [PhotoParameters]) {
        
        uploadState = .upload
        
        let headers: HTTPHeaders = [
            .authorization(bearerToken: loginModel!.data.apiToken),
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
            photos: photoParameters
        )
        
        AF.request(serverURL + "inspection", method: .post, parameters: parameters, encoder: JSONParameterEncoder.default, headers: headers)
            .validate()
            .uploadProgress { progress in
                self.uploadProgress = progress.fractionCompleted
            }
            .response { response in
                switch response.result {
                case .success:
                    #if !os(watchOS)
                    SPAlert.present(title: "Успешно!", message: "Осмотр успешно загружен на сервер.", preset: .done)
                    #endif
                    self.uploadState = .none
                    self.openCreateInspections = false
                case .failure(let error):
                    #if !os(watchOS)
                    SPAlert.present(title: "Ошибка!", message: "Попробуйте сохранить осмотр и загрузить его позднее.", preset: .error)
                    #endif
                    self.uploadState = .none
                    print(error.errorDescription!)
            }
        }
    }
    
    func uploadVyplatnyeDela(insuranceContractNumber: String, numberZayavlenia: String, latitude: Double, longitude: Double, photos: [PhotoParameters]) {
        
        uploadState = .upload
        
        let headers: HTTPHeaders = [
            .authorization(bearerToken: loginModel!.data.apiToken),
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
            .uploadProgress { progress in
                self.uploadProgress = progress.fractionCompleted
            }
            .response { response in
                switch response.result {
                case .success:
                    #if !os(watchOS)
                    SPAlert.present(title: "Успешно!", message: "Выплатное дело успешно загружено на сервер.", preset: .done)
                    self.uploadState = .none
                    self.openCreateVyplatnyeDela = false
                    #endif
                case .failure(let error):
                    #if !os(watchOS)
                    SPAlert.present(title: "Ошибка!", message: "Попробуйте загрузить позднее.", preset: .error)
                    #endif
                    self.uploadState = .none
                    print(error.errorDescription!)
            }
        }
    }
}

extension Defaults.Keys {
    static let loginModel = Key<LoginModel?>("loginModel", default: nil)
    static let loginParameters = Key<LoginParameters?>("loginParameters", default: nil)
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

