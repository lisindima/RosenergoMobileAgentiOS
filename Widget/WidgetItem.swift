//
//  WidgetItem.swift
//  RosenergoMobileAgent (Widget)
//
//  Created by Дмитрий Лисин on 01.10.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct WidgetItems: View {
    var localInspections: LocalInspections
    
    var body: some View {
        HStack {
            if let data = localInspections.localPhotos.first?.photosData {
                Image(uiImage: UIImage(data: data)!.resizedImage(width: 50, height: 50))
                    .resizable()
                    .cornerRadius(8)
                    .frame(width: 50, height: 50)
            }
            VStack(alignment: .leading) {
                Group {
                    Text(localInspections.insuranceContractNumber.uppercased())
                        .font(.caption)
                        .fontWeight(.bold)
                    if let insuranceContractNumber2 = localInspections.insuranceContractNumber2 {
                        Text(insuranceContractNumber2.uppercased())
                            .fontWeight(.bold)
                            .font(.caption)
                    }
                    Text(localInspections.dateInspections, style: .date)
                        .font(.caption)
                }
                .font(.footnote)
                .foregroundColor(.white)
                .lineLimit(1)
            }
            Spacer()
        }.padding(.vertical, 6)
    }
}
