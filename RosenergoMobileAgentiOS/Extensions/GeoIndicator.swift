//
//  GeoIndicator.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 08.06.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct GeoIndicator: View {
    
    @ObservedObject private var locationStore = LocationStore.shared
    @EnvironmentObject var sessionStore: SessionStore
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .foregroundColor(Color.red.opacity(0.2))
                .frame(minWidth: nil, idealWidth: nil, maxWidth: .infinity, minHeight: 30, idealHeight: 30, maxHeight: 30)
            HStack {
                Spacer()
                Text("Широта: \(locationStore.latitude)")
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                Spacer()
                Text("Долгота: \(locationStore.longitude)")
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                Spacer()
            }
        }
    }
}
