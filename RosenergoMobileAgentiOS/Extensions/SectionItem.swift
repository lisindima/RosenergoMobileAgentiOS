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
    var subTitle: String = ""
    var title: String?
    
    var secondaryTitle: Text {
        #if os(watchOS)
        return Text(subTitle)
            .font(.system(size: 11))
        #else
        return Text(subTitle)
            .font(.caption)
        #endif
    }
    
    var primaryTitle: Text {
        #if os(watchOS)
        return Text(title ?? "Пролетарская, 114")
            .font(.footnote)
        #else
        return Text(title ?? "Пролетарская, 114")
        #endif
    }
    
    var body: some View {
        HStack {
            Image(systemName: imageName)
                .frame(width: 24)
                .foregroundColor(imageColor)
            VStack(alignment: .leading) {
                if !subTitle.isEmpty {
                    secondaryTitle
                        .foregroundColor(.secondary)
                }
                primaryTitle
                    .foregroundColor(.primary)
                    .redacted(reason: title == nil ? .placeholder : [])
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
        Button(action: action) {
            HStack {
                Image(systemName: imageName)
                    .frame(width: 24)
                    .foregroundColor(imageColor)
                Text(title)
                    .foregroundColor(titleColor)
            }
        }
    }
}

struct SectionLink: View {
    var imageName: String
    var imageColor: Color
    var title: String?
    var titleColor: Color
    var showLinkLabel: Bool = false
    var destination: URL
    
    var primaryTitle: Text {
        #if os(watchOS)
        return Text(title ?? "Пролетарская, 114")
            .font(.footnote)
        #else
        return Text(title ?? "Пролетарская, 114")
        #endif
    }
    
    var body: some View {
        Link(destination: destination) {
            HStack {
                Image(systemName: imageName)
                    .frame(width: 24)
                    .foregroundColor(imageColor)
                primaryTitle
                    .foregroundColor(titleColor)
                    .redacted(reason: title == nil ? .placeholder : [])
                if showLinkLabel {
                    Spacer()
                    Image(systemName: "arrow.up.right.square")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

struct SectionItem_Previews: PreviewProvider {
    static var previews: some View {
        SectionItem(
            imageName: "map",
            imageColor: .rosenergo,
            subTitle: "Адрес места проведения осмотра",
            title: "Пролетарская, 114"
        )
    }
}
