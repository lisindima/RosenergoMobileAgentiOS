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
                    Text("Номер полиса: \(localInspections.insuranceContractNumber!)")
                    Text("Модель авто: \(localInspections.carModel!)")
                    Text("Рег.номер: \(localInspections.carRegNumber!)")
                    Text("VIN: \(localInspections.carVin!)")
                    Text("Номер кузова: \(localInspections.carBodyNumber!)")
                }
                .font(.footnote)
                .foregroundColor(.secondary)
                .lineLimit(1)
                if localInspections.carModel2 != nil {
                    Group {
                        Text("Номер полиса: \(localInspections.insuranceContractNumber2!)")
                            .padding(.top, 8)
                        Text("Модель авто: \(localInspections.carModel2!)")
                        Text("Рег.номер: \(localInspections.carRegNumber2!)")
                        Text("VIN: \(localInspections.carVin2!)")
                        Text("Номер кузова: \(localInspections.carBodyNumber2!)")
                    }
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                }
            }
            Spacer()
            if !localInspections.photos!.isEmpty {
                Image(uiImage: UIImage(data: Data.init(base64Encoded: localInspections.photos!.first!, options: .ignoreUnknownCharacters)!)!)
                    .resizable()
                    .cornerRadius(10)
                    .frame(width: 100, height: 100)
            }
        }
    }
}
