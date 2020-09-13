//
//  Log.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 13.09.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

func log(_ item: Any) {
    #if DEBUG
    print(item)
    #endif
}
