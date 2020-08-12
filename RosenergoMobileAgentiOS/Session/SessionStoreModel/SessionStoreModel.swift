//
//  SessionStoreModel.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 26.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

// MARK: Параметры для загрузки осмотров и выплатных дел.

struct VyplatnyeDelaParameters: Encodable {
    let insurance_contract_number: String
    let number_zayavlenia: String
    let latitude: Double
    let longitude: Double
    let photos: [PhotoParameters]
}

struct LinkInspections: Codable, Identifiable {
    let id, agentID: Int
    let carModel, carRegNumber, carVin, carBodyNumber: String
    let insuranceContractNumber: String
    let carModel2, carRegNumber2, carVin2, carBodyNumber2: String?
    let insuranceContractNumber2: String?
    let createdAt: String
    let latitude, longitude: Double
    let video: String?

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
        case createdAt = "created_at"
        case latitude, longitude
        case video
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
    let video: String?
    let photos: [PhotoParameters]
}

struct PhotoParameters: Encodable, Equatable {
    let latitude: Double
    let longitude: Double
    let file: String
    let maked_photo_at: String
}

// MARK: Параметры для логина в приложение.

struct LoginParameters: Codable {
    let email: String
    let password: String
}

// MARK: Codable модель для разбора списка осмотров.

struct Inspections: Codable, Identifiable {
    let id, agentID: Int
    let carModel, carRegNumber, carVin, carBodyNumber: String
    let insuranceContractNumber: String
    let carModel2, carRegNumber2, carVin2, carBodyNumber2: String?
    let insuranceContractNumber2: String?
    let createdAt: String
    let latitude, longitude: Double
    let photos: [Photo]
    let video: String?

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
        case createdAt = "created_at"
        case latitude, longitude
        case photos
        case video
    }
}

// MARK: Codable модель для разбора массива фотографий.

struct Photo: Codable, Identifiable {
    let id: Int
    let path: String
    let latitude, longitude: Double
    let createdAt, updatedAt, makedPhotoAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case path, latitude, longitude
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case makedPhotoAt = "maked_photo_at"
    }
}

// MARK: Codable модель для разбора списка выплатных дел.

struct Vyplatnyedela: Codable, Identifiable {
    let id, agentID: Int
    let insuranceContractNumber, numberZayavlenia: String
    let latitude, longitude: Double
    let createdAt, updatedAt: String
    let photos: [Photo]

    enum CodingKeys: String, CodingKey {
        case id
        case agentID = "agent_id"
        case insuranceContractNumber = "insurance_contract_number"
        case numberZayavlenia = "number_zayavlenia"
        case latitude, longitude
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case photos
    }
}

// MARK: Codable модель для загрузки данных пользователя.

struct LoginModel: Codable {
    let data: DataClass
}

struct DataClass: Codable, Identifiable {
    let id, roleID: Int
    let name, email, avatar: String
    let createdAt, updatedAt, apiToken: String
    let agentID: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case roleID = "role_id"
        case name, email, avatar
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case apiToken = "api_token"
        case agentID = "agent_id"
    }
}
