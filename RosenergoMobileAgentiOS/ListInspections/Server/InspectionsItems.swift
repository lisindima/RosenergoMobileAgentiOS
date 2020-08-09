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
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text("\(inspection.id)")
                    .foregroundColor(.rosenergo)
                    .fontWeight(.bold)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(Color.rosenergo.opacity(0.2))
                    )
                HStack {
                    VStack(alignment: .leading) {
                        Text(inspection.insuranceContractNumber)
                        Text(inspection.carModel)
                        //Text(inspection.carRegNumber)
                        //Text(inspection.carVin)
                        //Text(inspection.carBodyNumber)
                    }
                    if inspection.carModel2 != nil {
                        VStack(alignment: .leading) {
                            Text(inspection.insuranceContractNumber2!)
                            Text(inspection.carModel2!)
                            //Text(inspection.carRegNumber2!)
                            //Text(inspection.carVin2!)
                            //Text(inspection.carBodyNumber2!)
                        }
                    }
                }
                .font(.footnote)
                .foregroundColor(.secondary)
                .lineLimit(1)
            }
            Spacer()
            if !inspection.photos.isEmpty {
                URLImage(URL(string: inspection.photos.first!.path)!, delay: 0.25, processors: [Resize(size: CGSize(width: size, height: size), scale: scale)], placeholder: { _ in
                    ProgressView()
                }, content: {
                    $0.image
                        .resizable()
                })
                .cornerRadius(8)
                .frame(width: CGFloat(size), height: CGFloat(size))
            }
        }.padding(.vertical, 6)
    }
}
