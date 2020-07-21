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
        Label(title: {
            VStack(alignment: .leading) {
                Text(subTitle)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                primaryTitle
                    .foregroundColor(.primary)
            }
        }, icon: {
            Image(systemName: imageName)
                .foregroundColor(imageColor)
                .offset(x: 0, y: 11)
        })
    }
}

struct SectionButton: View {
    
    var imageName: String
    var imageColor: Color
    var title: String
    var titleColor: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label(title: {
                Text(title)
                    .foregroundColor(titleColor)
            }, icon: {
                Image(systemName: imageName)
                    .foregroundColor(imageColor)
            })
        }
    }
}

struct SectionProgress: View {
    
    var title: String
    
    var body: some View {
        HStack {
            ProgressView()
                .padding(.leading, 4)
            Text(title)
                .padding(.leading, 14)
        }
    }
}
