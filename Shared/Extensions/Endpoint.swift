//
//  Endpoint.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 21.09.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

enum Endpoint {
    case login
    case logout
    case uploadInspection
    case uploadVyplatnyedela
    case inspections(_ id: String)
    case vyplatnyedela(_ id: String)
    case license
    case changelog
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
            return .makeForEndpoint(id == "" ? "v2/inspections" : "v2/inspections" + "/\(id)")
        case let .vyplatnyedela(id):
            return .makeForEndpoint(id == "" ? "v2/vyplatnyedelas" : "v2/vyplatnyedelas" + "/\(id)")
        case .changelog:
            return URL(string: "https://api.lisindmitriy.me/changelog")!
        case .license:
            return URL(string: "https://api.lisindmitriy.me/license")!
        }
    }
}

extension URL {
    static func makeForEndpoint(_ endpoint: String) -> URL {
        URL(string: "https://rosenergo.calcn1.ru/api/\(endpoint)")!
    }
}
