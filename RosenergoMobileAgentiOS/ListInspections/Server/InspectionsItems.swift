//
//  InspectionsItems.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 23.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

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
                if inspection.carModel2 != nil {
                    Divider()
                    Group {
                        Text("Номер полиса: \(inspection.insuranceContractNumber2!)")
                        Text("Модель авто: \(inspection.carModel2!)")
                        Text("Рег.номер: \(inspection.carRegNumber2!)")
                        Text("VIN: \(inspection.carVin2!)")
                        Text("Номер кузова: \(inspection.carBodyNumber2!)")
                    }
                    .font(.footnote)
                    .foregroundColor(.secondary)
                }
            }
            Spacer()
            if !inspection.photos.isEmpty {
                ZStack {
                    WebImage(url: URL(string: inspection.photos.first!.path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!))
                        .resizable()
                        .indicator(.activity)
                        .cornerRadius(10)
                        .frame(width: 100, height: 100)
                    ZStack {
                        Circle()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.rosenergo)
                        Text("\(inspection.photos.count)")
                            .foregroundColor(.white)
                    }.offset(x: 45, y: -45)
                }
            }
        }
    }
}
