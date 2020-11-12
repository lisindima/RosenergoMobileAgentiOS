//
//  Enum.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 09.09.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

enum LoadingState<Value> {
    case loading
    case empty
    case success(_ value: Value)
    case failure(_ error: Error)
}

enum URLType: Identifiable {
    case inspection(_ id: String = "")
    case vyplatnyedela(_ id: String = "")
    
    var id: Int {
            switch self {
            case .inspection:
                return 0
            case .vyplatnyedela:
                return 1
            }
        }
}

enum Endpoint {
    case login
    case logout
    case uploadInspection
    case uploadVyplatnyedela
    case inspections(_ id: String = "")
    case vyplatnyedela(_ id: String = "")
}

enum Series: String, CaseIterable, Identifiable {
    case XXX = "ХХХ"
    case CCC = "ССС"
    case PPP = "РРР"
    case HHH = "ННН"
    case MMM = "МММ"
    case KKK = "ККК"
    case EEE = "ЕЕЕ"
    case BBB = "ВВВ"
    
    var id: String { rawValue }
}

enum FileType {
    case photo, video
}

enum HapticType {
    case error, success, warning
}

enum ApiError: Error {
    case uploadFailed(_ error: Error)
    case decodeFailed(_ error: Error)
}

enum HTTPMethod: String {
    case post = "POST"
    case get = "GET" 
}

enum Car {
    case oneCar
    case twoCar
}

enum CameraMode {
    case photo
    case video
}
