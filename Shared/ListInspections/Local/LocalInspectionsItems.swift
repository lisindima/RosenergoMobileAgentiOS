//
//  LocalInspectionsItems.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 23.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct LocalInspectionsItems: View {
    var localInspections: LocalInspections
    
    var body: some View {
        HStack {
            if let data = localInspections.localPhotos.first?.photosData {
                LocalImage(data: data)
            }
            VStack(alignment: .leading) {
                Text("Не отправлено")
                    .foregroundColor(.red)
                    .fontWeight(.bold)
                Group {
                    Text(localInspections.insuranceContractNumber.uppercased())
                        .fontWeight(.bold)
                    if let insuranceContractNumber2 = localInspections.insuranceContractNumber2 {
                        Text(insuranceContractNumber2.uppercased())
                            .fontWeight(.bold)
                    }
                    Text(localInspections.dateInspections, style: .relative)
                }
                .font(.footnote)
                .foregroundColor(.secondary)
                .lineLimit(1)
            }
            Spacer()
        }.padding(.vertical, 6)
    }
}
