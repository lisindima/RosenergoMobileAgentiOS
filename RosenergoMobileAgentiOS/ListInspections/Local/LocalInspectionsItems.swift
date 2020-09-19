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
    
    var size: CGFloat {
        #if os(watchOS)
        return 75.0
        #else
        return 100.0
        #endif
    }
    
    var body: some View {
        HStack {
            if let data = localInspections.arrayPhoto.first?.photosData {
                Image(uiImage: UIImage(data: data)!.resizedImage(width: size, height: size))
                    .resizable()
                    .cornerRadius(8)
                    .frame(width: size, height: size)
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
