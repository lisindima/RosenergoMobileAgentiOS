//
//  GeoIndicator.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 08.06.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import CoreLocation

struct GeoIndicator: View {
    
    @EnvironmentObject private var locationStore: LocationStore
    
    private let status = CLLocationManager().authorizationStatus()
    private let settingsURL = URL(string: UIApplication.openSettingsURLString)
    
    var body: some View {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            HStack {
                Spacer()
                Text("Широта: \(locationStore.latitude)")
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
                Text("Долгота: \(locationStore.longitude)")
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(Color.rosenergo)
            )
        } else {
            Link(destination: settingsURL!) {
                HStack {
                    Spacer()
                    Text("Не разрешен доступ к геопозиции!")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                    Spacer()
                }
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(Color.red.opacity(0.2))
                )
            }
        }
    }
}
