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

class SessionStore: ObservableObject {
    
    @Published var loginModel: LoginModel?
    @Published var inspections: [Inspections] = [Inspections]()
    @Published var imageLocalInspections: [Data] = [Data]()
    @Published var loadingLogin: Bool = false
    @Published var uploadProgress: Double = 0.0
    @Published var failureLoadingInspections: Bool = false
    
    static let shared = SessionStore()
    let serverURL: String = "https://rosenergo.calcn1.ru/api/"
    
    func login(email: String, password: String) {
        loadingLogin = true
        let parameters = LoginParameters(email: email, password: password)
        AF.request(serverURL + "login", method: .post, parameters: parameters)
            .validate()
            .responseDecodable(of: LoginModel.self) { response in
                switch response.result {
                case .success( _):
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
    
    func logout(apiToken: String) {
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(apiToken)",
            "Accept": "application/json"
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
    
    func validateToken(apiToken: String) {
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(apiToken)",
            "Accept": "application/json"
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
    
    func getInspections(apiToken: String) {
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(apiToken)",
            "Accept": "application/json"
        ]
        
        AF.request(serverURL + "inspections", method: .get, headers: headers)
            .validate()
            .responseDecodable(of: [Inspections].self) { response in
                switch response.result {
                case .success( _):
                    guard let inspections = response.value else { return }
                    self.inspections = inspections
                    self.failureLoadingInspections = false
                case .failure(let error):
                    self.failureLoadingInspections = true
                    print(error.errorDescription!)
                }
        }
    }
    
    func uploadInspections(apiToken: String) {
        AF.request(serverURL + "inspection", method: .post)
            .validate()
            .downloadProgress { progress in
                print("Download Progress: \(progress.fractionCompleted)")
            }
            .response { response in
                debugPrint("Response: \(response)")
            }
    }
    
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
