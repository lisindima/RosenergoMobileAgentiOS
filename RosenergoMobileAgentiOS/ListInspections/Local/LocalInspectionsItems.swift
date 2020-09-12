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
        HStack(alignment: .top) {
            if !localInspections.arrayPhoto.isEmpty {
                Image(uiImage: UIImage(data: localInspections.arrayPhoto.first!.photosData)!.resizedImage(width: size, height: size))
                    .resizable()
                    .cornerRadius(8)
                    .frame(width: size, height: size)
            }
            VStack(alignment: .leading) {
                Text("Не отправлено")
                    .foregroundColor(.red)
                    .fontWeight(.bold)
                HStack {
                    VStack(alignment: .leading) {
                        Text(localInspections.insuranceContractNumber)
                        Text(localInspections.carModel)
                        Text(localInspections.carRegNumber)
                        Text(localInspections.carVin)
                        Text(localInspections.carBodyNumber)
                    }
                    if localInspections.carModel2 != nil {
                        VStack(alignment: .leading) {
                            Text(localInspections.insuranceContractNumber2!)
                            Text(localInspections.carModel2!)
                            Text(localInspections.carRegNumber2!)
                            Text(localInspections.carVin2!)
                            Text(localInspections.carBodyNumber2!)
                        }
                    }
                }
                .font(.footnote)
                .foregroundColor(.secondary)
                .lineLimit(1)
            }
            Spacer()
            Text(localInspections.dateInspections, style: .relative)
                .font(.footnote)
                .foregroundColor(.secondary)
        }.padding(.vertical, 6)
    }
}
