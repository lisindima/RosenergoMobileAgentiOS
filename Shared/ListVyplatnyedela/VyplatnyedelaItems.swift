//
//  VyplatnyedelaItems.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 30.07.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct VyplatnyedelaItems: View {
    var vyplatnyedela: Vyplatnyedela
    
    var body: some View {
        HStack {
            if let path = vyplatnyedela.photos.first?.path {
                ServerImage(path, delay: 0.25)
            }
            VStack(alignment: .leading) {
                Text(vyplatnyedela.id.toString())
                    .fontWeight(.bold)
                Group {
                    Text(vyplatnyedela.insuranceContractNumber.uppercased())
                        .fontWeight(.bold)
                    Text(vyplatnyedela.numberZayavlenia.uppercased())
                        .fontWeight(.bold)
                    Text(vyplatnyedela.createdAt, style: .relative)
                }
                .font(.footnote)
                .foregroundColor(.secondary)
                .lineLimit(1)
            }
            Spacer()
        }.padding(.vertical, 6)
    }
}
