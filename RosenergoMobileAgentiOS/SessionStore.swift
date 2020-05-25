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
import SPAlert
import Defaults
import CoreLocation

class SessionStore: ObservableObject {
    
    @Default(.loginModel) var loginModel
    
    @Published var inspections: [Inspections] = [Inspections]()
    @Published var photoParameters: [PhotoParameters] = [PhotoParameters]()
    @Published var imageLocalInspections: [String] = [String]()
    @Published var loadingLogin: Bool = false
    @Published var inspectionUploadState: InspectionUploadState = .none
    @Published var inspectionsLoadingState: InspectionsLoadingState = .loading
    @Published var latitude: Double = 0.0
    @Published var longitude: Double = 0.0
    @Published var uploadProgress: Double = 0.0
    
    static let shared = SessionStore()
    
    let serverURL: String = "https://rosenergo.calcn1.ru/api/"
    
    var locationManager = CLLocationManager()
    
    enum InspectionsLoadingState {
        case loading, failure, success
    }
    
    enum InspectionUploadState {
        case upload, none
    }
    
    let stringDate: String = {
        var currentDate: Date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let createStringDate = dateFormatter.string(from: currentDate)
        return createStringDate
    }()
    
    func getLocation() {
        locationManager.requestWhenInUseAuthorization()
        var currentLoc: CLLocation!
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == .authorizedAlways {
            currentLoc = locationManager.location
            latitude = currentLoc.coordinate.latitude
            longitude = currentLoc.coordinate.longitude
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
            .responseDecodable(of: LoginModel.self) { response in
                switch response.result {
                case .success:
                    guard let loginModel = response.value else { return }
                    self.loginModel = loginModel
                    self.loadingLogin = false
                case .failure(let error):
                    SPAlert.present(title: "Ошибка!", message: "Неправильный логин или пароль.", preset: .error)
                    print(error.errorDescription!)
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
                case .failure(let error):
                    self.loginModel = nil
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
                switch response.result {
                case .success(let data):
                    print(data)
                case .failure(let error):
                    print(error.errorDescription!)
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
        
        inspectionUploadState = .upload
        
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
            .downloadProgress { progress in
                self.uploadProgress = progress.fractionCompleted
            }
            .response { response in
                switch response.result {
                case .success:
                    SPAlert.present(title: "Успешно!", message: "Осмотр успешно загружен на сервер.", preset: .done)
                    self.inspectionUploadState = .none
                case .failure(let error):
                    SPAlert.present(title: "Ошибка!", message: "Попробуйте сохранить осмотр и загрузить его позднее.", preset: .error)
                    self.inspectionUploadState = .none
                    print(error.errorDescription!)
            }
        }
    }
}

struct InspectionParameters: Encodable {
    let car_model: String
    let car_reg_number: String
    let car_body_number: String
    let car_vin: String
    let insurance_contract_number: String
    let car_model2: String?
    let car_reg_number2: String?
    let car_body_number2: String?
    let car_vin2: String?
    let insurance_contract_number2: String?
    let latitude: Double
    let longitude: Double
    let photos: [PhotoParameters]
}

struct PhotoParameters: Encodable {
    let latitude: Double
    let longitude: Double
    let file: String
    let maked_photo_at: String
}

struct LoginParameters: Encodable {
    let email: String
    let password: String
}

struct Inspections: Codable, Identifiable {
    let id, agentID: Int
    let carModel, carRegNumber, carVin, carBodyNumber: String
    let insuranceContractNumber: String
    let carModel2, carRegNumber2, carVin2, carBodyNumber2: String?
    let insuranceContractNumber2: String?
    let createdat: String
    let latitude, longitude: Double
    let photos: [Photo]

    enum CodingKeys: String, CodingKey {
        case id
        case agentID = "agent_id"
        case carModel = "car_model"
        case carRegNumber = "car_reg_number"
        case carVin = "car_vin"
        case carBodyNumber = "car_body_number"
        case insuranceContractNumber = "insurance_contract_number"
        case carModel2 = "car_model2"
        case carRegNumber2 = "car_reg_number2"
        case carVin2 = "car_vin2"
        case carBodyNumber2 = "car_body_number2"
        case insuranceContractNumber2 = "insurance_contract_number2"
        case createdat = "created_at"
        case latitude, longitude
        case photos
    }
}

struct Photo: Codable, Identifiable {
    let id, inspectionID: Int
    let path: String
    let latitude, longitude: Double
    let createdAt, updatedAt, makedPhotoAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case inspectionID = "inspection_id"
        case path, latitude, longitude
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case makedPhotoAt = "maked_photo_at"
    }
}

struct LoginModel: Codable {
    let data: DataClass
}

struct DataClass: Codable, Identifiable {
    let id, roleID: Int
    let name, email, avatar: String
    let settings: Settings
    let createdAt, updatedAt, apiToken: String
    let agentID: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case roleID = "role_id"
        case name, email, avatar, settings
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case apiToken = "api_token"
        case agentID = "agent_id"
    }
}

struct Settings: Codable {
    let locale: String
}

extension Defaults.Keys {
    static let loginModel = Key<LoginModel?>("loginModel", default: nil)
}
