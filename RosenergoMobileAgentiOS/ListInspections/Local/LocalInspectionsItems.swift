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
                }
                .font(.footnote)
                .foregroundColor(.secondary)
                .lineLimit(1)
                if localInspections.carModel2 != nil {
                    Group {
                        Text(localInspections.insuranceContractNumber2!).padding(.top, 8)
                        Text(localInspections.carModel2!)
                        Text(localInspections.carRegNumber2!)
                        Text(localInspections.carVin2!)
                        Text(localInspections.carBodyNumber2!)
                    }
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                }
            }
            Spacer()
            if !localInspections.photos!.isEmpty {
                Image(uiImage: UIImage(data: Data(base64Encoded: localInspections.photos!.first!, options: .ignoreUnknownCharacters)!)!.resize(size: CGSize(width: 100, height: 100), scale: UIScreen.main.scale))
                    .resizable()
                    .cornerRadius(10)
                    .frame(width: 100, height: 100)
            }
        }
    }
}
