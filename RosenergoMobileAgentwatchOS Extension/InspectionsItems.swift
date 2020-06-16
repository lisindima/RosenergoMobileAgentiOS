//
//  InspectionsItems.swift
//  RosenergoMobileAgentwatchOS Extension
//
//  Created by Дмитрий Лисин on 16.06.2020.
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
                WebImage(url: URL(string: inspection.photos.first!.path))
                    .resizable()
                    //.indicator(.activity)
                    .cornerRadius(10)
                    .frame(width: 75, height: 75)
            }
        }
    }
}
