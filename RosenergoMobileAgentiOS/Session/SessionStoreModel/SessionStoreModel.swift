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
    let id, agentId: Int
    let carModel, carRegNumber, carVin, carBodyNumber: String
    let insuranceContractNumber: String
    let carModel2, carRegNumber2, carVin2, carBodyNumber2: String?
    let insuranceContractNumber2: String?
    let createdAt: String
    let latitude, longitude: Double
    let photos: [Photo]
    let video: String?
}

// MARK: Codable модель для разбора массива фотографий.

struct Photo: Codable, Identifiable {
    let id: Int
    let path: URL
    let latitude, longitude: Double
    let createdAt, updatedAt, makedPhotoAt: String
}

// MARK: Codable модель для разбора списка выплатных дел.

struct Vyplatnyedela: Codable, Identifiable {
    let id, agentId: Int
    let insuranceContractNumber, numberZayavlenia: String
    let latitude, longitude: Double
    let createdAt, updatedAt: String
    let photos: [Photo]
}

// MARK: Codable модель для загрузки данных пользователя.

struct LoginModel: Codable {
    let data: DataClass
}

struct DataClass: Codable, Identifiable {
    let id, roleId: Int
    let name, email, avatar: String
    let createdAt, updatedAt, apiToken: String
    let agentId: Int
}

// MARK: Codable модель для загрузки списка изменений.

struct ChangelogModel: Identifiable, Codable {
    let id: Int
    let version, dateBuild, whatsNew, bugFixes: String
}

// MARK: Codable модель для загрузки списка лицензий.

struct LicenseModel: Identifiable, Codable {
    let id: Int
    let nameFramework, urlFramework, textLicenseFramework: String
}

// MARK: Модель для отображения уведомлений.

struct AlertItem: Identifiable {
    var id: String { message }
    var title: String
    var message: String
    var action: Bool
}
