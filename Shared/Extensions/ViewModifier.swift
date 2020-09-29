//
//  ViewModifier.swift
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

struct ListStyle: ViewModifier {
    func body(content: Content) -> some View {
        #if os(watchOS)
        return content
        #else
        return content
            .listStyle(InsetGroupedListStyle())
        #endif
    }
}

extension Text {
    func errorTitle() -> Text {
        #if os(watchOS)
        return self
            .fontWeight(.bold)
        #else
        return self
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(.secondary)
        #endif
    }
    
    func errorSubtitle() -> Text {
        #if os(watchOS)
        return self
            .font(.footnote)
            .foregroundColor(.secondary)
        #else
        return self
            .foregroundColor(.secondary)
        #endif
    }
}
