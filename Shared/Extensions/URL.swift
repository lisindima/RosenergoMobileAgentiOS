//
//  URL.swift
//  RosenergoMobileAgent
//
//  Created by Дмитрий Лисин on 05.11.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import Foundation

extension URL {
    subscript(queryParam: String) -> String {
        guard let url = URLComponents(string: absoluteString) else { return "" }
        return url.queryItems?.first(where: { $0.name == queryParam })?.value ?? ""
    }
}
