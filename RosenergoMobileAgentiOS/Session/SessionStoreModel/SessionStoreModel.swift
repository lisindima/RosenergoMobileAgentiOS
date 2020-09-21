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
    let insuranceContractNumber: String
    let numberZayavlenia: String
    let latitude: Double
    let longitude: Double
    let photos: [PhotoParameters]
}

struct InspectionParameters: Encodable {
    let carModel: String
    let carRegNumber: String
    let carBodyNumber: String
    let carVin: String
    let insuranceContractNumber: String
    let carModel2: String?
    let carRegNumber2: String?
    let carBodyNumber2: String?
    let carVin2: String?
    let insuranceContractNumber2: String?
    let latitude: Double
    let longitude: Double
    let video: String?
    let photos: [PhotoParameters]
}

struct PhotoParameters: Encodable, Equatable {
    let latitude: Double
    let longitude: Double
    let file: String
    let makedPhotoAt: String
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
    let createdAt: Date
    let latitude, longitude: Double
    let photos: [Photo]
    let video: URL?
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
    let createdAt: Date
    let photos: [Photo]
}

// MARK: Codable модель для загрузки данных пользователя.

struct LoginModel: Codable, Identifiable {
    let id, roleId: Int
    let name, email, avatar: String
    let createdAt, updatedAt, apiToken: String
    let agentId: Int
}

extension LoginModel {
    struct NetworkResponse: Codable {
        let data: LoginModel
    }
}

// MARK: Codable модель для загрузки списка изменений.

struct ChangelogModel: Identifiable, Codable {
    let id: Int
    let version, dateBuild, whatsNew, bugFixes: String
}

// MARK: Codable модель для загрузки списка лицензий.

struct LicenseModel: Identifiable, Codable {
    let id: Int
    let urlFramework: URL
    let nameFramework, textLicenseFramework: String
}
