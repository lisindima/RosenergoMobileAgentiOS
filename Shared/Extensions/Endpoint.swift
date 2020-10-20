//
//  Endpoint.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 21.09.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import Combine
import Foundation

enum Endpoint {
    case login
    case logout
    case uploadInspection
    case uploadVyplatnyedela
    case inspections(_ id: String = "")
    case vyplatnyedela(_ id: String = "")
}

extension Endpoint {
    var url: URL {
        switch self {
        case .login:
            return .makeForEndpoint("login")
        case .logout:
            return .makeForEndpoint("logout")
        case .uploadInspection:
            return .makeForEndpoint("testinspection")
        case .uploadVyplatnyedela:
            return .makeForEndpoint("vyplatnyedela")
        case let .inspections(id):
            return .makeForEndpoint(id.isEmpty ? "v2/inspections" : "v2/inspections" + "/\(id)")
        case let .vyplatnyedela(id):
            return .makeForEndpoint(id.isEmpty ? "v2/vyplatnyedelas" : "v2/vyplatnyedelas" + "/\(id)")
        }
    }
}

extension URL {
    static func makeForEndpoint(_ endpoint: String) -> URL {
        URL(string: "https://rosenergo.calcn1.ru/api/\(endpoint)")!
    }
}
