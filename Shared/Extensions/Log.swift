//
//  Log.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 13.09.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import Firebase

func log(_ item: String) {
    #if DEBUG
    debugPrint(item)
    #else
    Crashlytics.crashlytics().log(item)
    #endif
}
