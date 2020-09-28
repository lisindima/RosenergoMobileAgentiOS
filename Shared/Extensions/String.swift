//
//  String.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 19.09.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

func getVersion() -> String {
    let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    let build = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
    return "\(version) (\(build))"
}
