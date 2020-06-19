//
//  InspectionsItems.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 23.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import URLImage

struct InspectionsItems: View {
    
    var inspection: Inspections
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(inspection.id)")
                    .font(.title)
                    .fontWeight(.bold)
                Group {
                    Text("Номер полиса: \(inspection.insuranceContractNumber)")
                    Text("Модель авто: \(inspection.carModel)")
                    Text("Рег.номер: \(inspection.carRegNumber)")
                    Text("VIN: \(inspection.carVin)")
                    Text("Номер кузова: \(inspection.carBodyNumber)")
                }
                .font(.footnote)
                .foregroundColor(.secondary)
                .lineLimit(1)
                if inspection.carModel2 != nil {
                    Group {
                        Text("Номер полиса: \(inspection.insuranceContractNumber2!)")
                            .padding(.top, 8)
                        Text("Модель авто: \(inspection.carModel2!)")
                        Text("Рег.номер: \(inspection.carRegNumber2!)")
                        Text("VIN: \(inspection.carVin2!)")
                        Text("Номер кузова: \(inspection.carBodyNumber2!)")
                    }
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                }
            }
            Spacer()
            if !inspection.photos.isEmpty {
                URLImage(URL(string: inspection.photos.first!.path)!, processors: [Resize(size: CGSize(width: 100.0, height: 100.0), scale: UIScreen.main.scale)], placeholder: { _ in
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
