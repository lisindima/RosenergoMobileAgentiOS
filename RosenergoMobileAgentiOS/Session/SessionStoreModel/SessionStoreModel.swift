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

struct PhotoParameters: Encodable, Equatable {
    let latitude: Double
    let longitude: Double
    let file: String
    let maked_photo_at: String
}

// MARK: Параметры для запроса в Яндекс Геокодер.

struct YandexGeoParameters: Encodable {
    let apikey: String
    let format: String
    let geocode: String
    let results: String
    let kind: String
}

// MARK: Параметры для логина в приложение.

struct LoginParameters: Codable {
    let email: String
    let password: String
}

struct LocationAgentUpdate: Codable {
    let latitude: Double
    let longitude: Double
}

// MARK: Codable модель для разбора списка осмотров.

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

// MARK: Codable модель для загрузки Яндекс Геокодера.

struct YandexGeo: Codable, Hashable {
    let response: Response
    
    enum CodingKeys: String, CodingKey {
        case response
    }
}

struct Response: Codable, Hashable {
    let geoObjectCollection: GeoObjectCollection

    enum CodingKeys: String, CodingKey {
        case geoObjectCollection = "GeoObjectCollection"
    }
}

struct GeoObjectCollection: Codable, Hashable {
    let featureMember: [FeatureMember]
    
    enum CodingKeys: String, CodingKey {
        case featureMember
    }
}

struct FeatureMember: Codable, Hashable {
    let geoObject: GeoObject

    enum CodingKeys: String, CodingKey {
        case geoObject = "GeoObject"
    }
}

struct GeoObject: Codable, Hashable {
    let metaDataProperty: MetaDataProperty
    let name, description: String?

    enum CodingKeys: String, CodingKey {
        case metaDataProperty
        case name
        case description
    }
}

struct MetaDataProperty: Codable, Hashable {
    let geocoderMetaData: GeocoderMetaData

    enum CodingKeys: String, CodingKey {
        case geocoderMetaData = "GeocoderMetaData"
    }
}

struct GeocoderMetaData: Codable, Hashable {
    let precision, text, kind: String?
    let address: Address

    enum CodingKeys: String, CodingKey {
        case precision, text, kind
        case address = "Address"
    }
}

struct Address: Codable, Hashable {
    let countryCode, formatted, postalCode: String?

    enum CodingKeys: String, CodingKey {
        case countryCode = "country_code"
        case formatted
        case postalCode = "postal_code"
    }
}
