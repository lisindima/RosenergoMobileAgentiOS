//
//  Enum.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 09.09.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

enum LoadingState {
    case loading, success, empty
    case failure(Error)
}

enum FileType {
    case photo, video
}

enum HapticType {
    case error, success, warning
}
