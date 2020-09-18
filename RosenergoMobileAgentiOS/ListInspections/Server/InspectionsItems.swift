//
//  InspectionsItems.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 23.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct InspectionsItems: View {
    var inspection: Inspections
    
    var body: some View {
        HStack {
            if let path = inspection.photos.first?.path {
                ServerImage(path, delay: 0.25)
            }
            VStack(alignment: .leading) {
                Text("\(inspection.id)")
                    .fontWeight(.bold)
                Group {
                    Text(inspection.insuranceContractNumber)
                    if let insuranceContractNumber2 = inspection.insuranceContractNumber2 {
                        Text(insuranceContractNumber2)
                    }
                    Text(inspection.createdAt, style: .relative)
                }
                .font(.footnote)
                .foregroundColor(.secondary)
                .lineLimit(1)
            }
            Spacer()
        }.padding(.vertical, 6)
    }
}
