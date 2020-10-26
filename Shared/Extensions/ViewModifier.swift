//
//  ViewModifier.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 08.09.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct TabViewBackgroundMode: ViewModifier {
    @ViewBuilder
    func body(content: Content) -> some View {
        #if os(watchOS)
        content
        #else
        content
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        #endif
    }
}

struct ListStyle: ViewModifier {
    @ViewBuilder
    func body(content: Content) -> some View {
        #if os(watchOS)
        content
        #else
        content
            .listStyle(InsetGroupedListStyle())
        #endif
    }
}

extension Text {
    @ViewBuilder
    func messageTitle() -> Text {
        #if os(watchOS)
        fontWeight(.bold)
        #else
        font(.title)
            .fontWeight(.bold)
            .foregroundColor(.secondary)
        #endif
    }
    
    @ViewBuilder
    func messageSubtitle() -> Text {
        #if os(watchOS)
        font(.footnote)
            .foregroundColor(.secondary)
        #else
        foregroundColor(.secondary)
        #endif
    }
}
