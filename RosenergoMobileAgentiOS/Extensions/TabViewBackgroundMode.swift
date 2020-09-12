//
//  TabViewBackgroundMode.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 08.09.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct TabViewBackgroundMode: ViewModifier {
    func body(content: Content) -> some View {
        #if os(watchOS)
        return content
        #else
        return content
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        #endif
    }
}
