//
//  VyplatnyedelaItems.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 31.07.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import URLImage

struct VyplatnyedelaItems: View {
    var vyplatnyedela: Vyplatnyedela
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text("\(vyplatnyedela.id)")
                    .font(.title)
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
            if !vyplatnyedela.photos.isEmpty {
                URLImage(URL(string: vyplatnyedela.photos.first!.path)!, processors: [Resize(size: CGSize(width: 100.0, height: 100.0), scale: UIScreen.main.scale)], placeholder: { _ in
                    ActivityIndicator(styleSpinner: .medium)
                }) { proxy in
                    proxy.image
                        .resizable()
                }
                .cornerRadius(10)
                .frame(width: 100, height: 100)
            }
        }
    }
}
