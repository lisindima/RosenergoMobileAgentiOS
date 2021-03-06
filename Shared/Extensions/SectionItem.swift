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
    var imageColor: Color = .rosenergo
    var subTitle: String = ""
    var title: String?
    var titleColor: Color = .primary
    
    @ViewBuilder var secondaryTitle: Text {
        #if os(watchOS)
        Text(subTitle)
            .font(.system(size: 11))
        #else
        Text(subTitle)
            .font(.caption)
        #endif
    }
    
    @ViewBuilder var primaryTitle: Text {
        #if os(watchOS)
        Text(title ?? "Пролетарская, 114")
            .font(.footnote)
        #else
        Text(title ?? "Пролетарская, 114")
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
                    .foregroundColor(titleColor)
                    .redacted(reason: title == nil ? .placeholder : [])
            }
        }
    }
}

struct SectionButton: View {
    var imageName: String
    var imageColor: Color = .rosenergo
    var title: String
    var titleColor: Color = .primary
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            SectionItem(
                imageName: imageName,
                imageColor: imageColor,
                title: title,
                titleColor: titleColor
            )
        }
    }
}

struct SectionLink: View {
    var imageName: String
    var imageColor: Color = .rosenergo
    var title: String?
    var titleColor: Color = .primary
    var showLinkLabel: Bool = false
    var url: URL?
    
    var body: some View {
        if let destination = url {
            Link(destination: destination) {
                HStack {
                    SectionItem(
                        imageName: imageName,
                        imageColor: imageColor,
                        title: title,
                        titleColor: titleColor
                    )
                    if showLinkLabel {
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

struct SectionNavigationLink<Destination: View>: View {
    var imageName: String
    var imageColor: Color = .rosenergo
    var title: String
    var titleColor: Color = .primary
    var destination: Destination
    
    var body: some View {
        NavigationLink(destination: destination) {
            SectionItem(
                imageName: imageName,
                imageColor: imageColor,
                title: title,
                titleColor: titleColor
            )
        }
    }
}

struct SectionItem_Previews: PreviewProvider {
    static var previews: some View {
        SectionItem(
            imageName: "map",
            subTitle: "Адрес места проведения осмотра",
            title: "Пролетарская, 114"
        )
    }
}
