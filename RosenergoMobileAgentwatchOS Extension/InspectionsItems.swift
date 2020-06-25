//
//  InspectionsItems.swift
//  RosenergoMobileAgentwatchOS Extension
//
//  Created by Дмитрий Лисин on 16.06.2020.
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
                    Text(inspection.insuranceContractNumber)
                    Text(inspection.carModel)
                    Text(inspection.carRegNumber)
                    Text(inspection.carVin)
                    Text(inspection.carBodyNumber)
                }
                .font(.footnote)
                .foregroundColor(.secondary)
                .lineLimit(1)
                if inspection.carModel2 != nil {
                    Group {
                        Text(inspection.insuranceContractNumber2!)
                            .padding(.top, 8)
                        Text(inspection.carModel2!)
                        Text(inspection.carRegNumber2!)
                        Text(inspection.carVin2!)
                        Text(inspection.carBodyNumber2!)
                    }
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                }
            }
            Spacer()
            if !inspection.photos.isEmpty {
                URLImage(URL(string: inspection.photos.first!.path)!, processors: [Resize(size: CGSize(width: 75.0, height: 75.0), scale: WKInterfaceDevice.current().screenScale)], placeholder: { _ in
                    ProgressView()
                }) { proxy in
                    proxy.image
                        .resizable()
                }
                .cornerRadius(10)
                .frame(width: 75, height: 75)
            }
        }
    }
}
