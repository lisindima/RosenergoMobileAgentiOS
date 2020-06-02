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
}

// MARK: Параметры для логина в приложение.

struct LoginParameters: Encodable {
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

// MARK: Codable модель для загрузки данных пользователя.

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

// MARK: Codable модель для загрузки Яндекс Геокодера.

struct YandexGeo: Codable, Hashable {
    let response: Response
}

struct Response: Codable, Hashable {
    let geoObjectCollection: GeoObjectCollection

    enum CodingKeys: String, CodingKey {
        case geoObjectCollection
    }
}

struct GeoObjectCollection: Codable, Hashable {
    let metaDataProperty: GeoObjectCollectionMetaDataProperty
    let featureMember: [FeatureMember]
}

struct FeatureMember: Codable, Hashable {
    let geoObject: GeoObject

    enum CodingKeys: String, CodingKey {
        case geoObject
    }
}

struct GeoObject: Codable, Hashable {
    let metaDataProperty: GeoObjectMetaDataProperty
    let name, geoObjectDescription: String
    let boundedBy: BoundedBy
    let point: Point

    enum CodingKeys: String, CodingKey {
        case metaDataProperty, name
        case geoObjectDescription
        case boundedBy
        case point
    }
}

struct BoundedBy: Codable, Hashable {
    let envelope: Envelope

    enum CodingKeys: String, CodingKey {
        case envelope
    }
}


struct Envelope: Codable, Hashable {
    let lowerCorner, upperCorner: String
}

struct GeoObjectMetaDataProperty: Codable, Hashable {
    let geocoderMetaData: GeocoderMetaData

    enum CodingKeys: String, CodingKey {
        case geocoderMetaData
    }
}

struct GeocoderMetaData: Codable, Hashable {
    let precision, text, kind: String
    let address: Address
    let addressDetails: AddressDetails

    enum CodingKeys: String, CodingKey {
        case precision, text, kind
        case address
        case addressDetails
    }
}

struct Address: Codable, Hashable {
    let countryCode, formatted, postalCode: String
    let components: [Component]

    enum CodingKeys: String, CodingKey {
        case countryCode
        case formatted
        case postalCode
        case components
    }
}

struct Component: Codable, Hashable {
    let kind, name: String
}

struct AddressDetails: Codable, Hashable {
    let country: Country

    enum CodingKeys: String, CodingKey {
        case country
    }
}

struct Country: Codable, Hashable {
    let addressLine, countryNameCode, countryName: String
    let administrativeArea: AdministrativeArea

    enum CodingKeys: String, CodingKey {
        case addressLine
        case countryNameCode
        case countryName
        case administrativeArea
    }
}

struct AdministrativeArea: Codable, Hashable {
    let administrativeAreaName: String
    let locality: Locality

    enum CodingKeys: String, CodingKey {
        case administrativeAreaName
        case locality
    }
}

struct Locality: Codable, Hashable {
    let localityName: String
    let thoroughfare: Thoroughfare

    enum CodingKeys: String, CodingKey {
        case localityName
        case thoroughfare
    }
}

struct Thoroughfare: Codable, Hashable {
    let thoroughfareName: String
    let premise: Premise

    enum CodingKeys: String, CodingKey {
        case thoroughfareName
        case premise
    }
}

struct Premise: Codable, Hashable {
    let premiseNumber: String
    let postalCode: PostalCode

    enum CodingKeys: String, CodingKey {
        case premiseNumber
        case postalCode
    }
}

struct PostalCode: Codable, Hashable {
    let postalCodeNumber: String

    enum CodingKeys: String, CodingKey {
        case postalCodeNumber
    }
}

struct Point: Codable, Hashable {
    let pos: String
}

struct GeoObjectCollectionMetaDataProperty: Codable, Hashable {
    let geocoderResponseMetaData: GeocoderResponseMetaData

    enum CodingKeys: String, CodingKey {
        case geocoderResponseMetaData
    }
}

struct GeocoderResponseMetaData: Codable, Hashable {
    let point: Point
    let request, results, found: String

    enum CodingKeys: String, CodingKey {
        case point
        case request, results, found
    }
}
