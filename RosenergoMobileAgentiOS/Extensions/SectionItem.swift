//
//  SectionItem.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 25.06.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct SectionItem: View {
    
    var imageName: String
    var imageColor: Color
    var subTitle: String
    var title: String
    
    @ViewBuilder var primaryTitle: Text {
        #if os(watchOS)
        Text(title)
            .font(.footnote)
        #else
        Text(title)
        #endif
    }
    
    var body: some View {
        HStack {
            Image(systemName: imageName)
                .frame(width: 24)
                .foregroundColor(imageColor)
            VStack(alignment: .leading) {
                Text(subTitle)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                primaryTitle
                    .foregroundColor(.primary)
            }
        }
    }
}

struct SectionButton: View {
    
    var imageName: String
    var imageColor: Color
    var title: String
    var titleColor: Color
    var action: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: imageName)
                .frame(width: 24)
                .foregroundColor(imageColor)
            Button(action: action) {
                Text(title)
                    .foregroundColor(titleColor)
            }
        }
    }
}
