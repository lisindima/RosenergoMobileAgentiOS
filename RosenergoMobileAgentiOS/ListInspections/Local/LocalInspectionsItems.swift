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
    
    var scale: CGFloat {
        #if os(watchOS)
        return WKInterfaceDevice.current().screenScale
        #else
        return UIScreen.main.scale
        #endif
    }
    
    var size: Double {
        #if os(watchOS)
        return 75.0
        #else
        return 100.0
        #endif
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Не отправлено")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                Group {
                    Text(localInspections.insuranceContractNumber!)
                    Text(localInspections.carModel!)
                    Text(localInspections.carRegNumber!)
                    Text(localInspections.carVin!)
                    Text(localInspections.carBodyNumber!)
                    if localInspections.carModel2 != nil {
                        Text(localInspections.insuranceContractNumber2!)
                            .padding(.top, 8)
                        Text(localInspections.carModel2!)
                        Text(localInspections.carRegNumber2!)
                        Text(localInspections.carVin2!)
                        Text(localInspections.carBodyNumber2!)
                    }
                }
                .font(.footnote)
                .foregroundColor(.secondary)
                .lineLimit(1)
            }
            Spacer()
            if !localInspections.photos!.isEmpty {
                #if os(iOS)
                Image(uiImage: UIImage(data: Data(base64Encoded: localInspections.photos!.first!, options: .ignoreUnknownCharacters)!)!.resize(size: CGSize(width: size, height: size), scale: scale))
                    .resizable()
                    .cornerRadius(10)
                    .frame(width: CGFloat(size), height: CGFloat(size))
                #else
                Image(uiImage: UIImage(data: Data(base64Encoded: localInspections.photos!.first!, options: .ignoreUnknownCharacters)!)!)
                    .resizable()
                    .cornerRadius(10)
                    .frame(width: CGFloat(size), height: CGFloat(size))
                #endif
            }
        }
    }
}
