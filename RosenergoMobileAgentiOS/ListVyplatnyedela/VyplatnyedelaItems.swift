//
//  VyplatnyedelaItems.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 30.07.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import URLImage

struct VyplatnyedelaItems: View {
    var vyplatnyedela: Vyplatnyedela

    var scale: CGFloat {
        #if os(watchOS)
            return WKInterfaceDevice.current().screenScale
        #else
            return UIScreen.main.scale
        #endif
    }

    var size: CGFloat {
        #if os(watchOS)
            return 75.0
        #else
            return 100.0
        #endif
    }

    var body: some View {
        HStack(alignment: .top) {
            if !vyplatnyedela.photos.isEmpty {
                URLImage(
                    vyplatnyedela.photos.first!.path,
                    delay: 0.25,
                    processors: [Resize(size: CGSize(width: size, height: size), scale: scale)],
                    placeholder: { _ in
                        ProgressView()
                    }
                ) {
                    $0.image
                        .resizable()
                }
                .cornerRadius(8)
                .frame(width: size, height: size)
            }
            VStack(alignment: .leading) {
                Text("\(vyplatnyedela.id)")
                    .fontWeight(.bold)
                Group {
                    Text(vyplatnyedela.insuranceContractNumber)
                    Text(vyplatnyedela.numberZayavlenia)
                }
                .font(.footnote)
                .foregroundColor(.secondary)
                .lineLimit(1)
            }
            Spacer()
            Text(vyplatnyedela.createdAt.calenderTimeSinceNow())
                .font(.footnote)
                .foregroundColor(.secondary)
        }.padding(.vertical, 6)
    }
}
