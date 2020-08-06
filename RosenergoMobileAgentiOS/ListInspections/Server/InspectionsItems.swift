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
                        Text(inspection.insuranceContractNumber2!).padding(.top, 8)
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
