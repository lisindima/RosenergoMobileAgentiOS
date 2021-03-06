//
//  GeoIndicator.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 08.06.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import CoreLocation
import SwiftUI

struct GeoIndicator: View {
    private let status = CLLocationManager().authorizationStatus
    private let settingsURL = URL(string: UIApplication.openSettingsURLString)!
    
    var latitude: Double
    var longitude: Double
    
    var body: some View {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            HStack {
                Spacer()
                VStack {
                    Text("Широта")
                        .font(.caption2)
                        .foregroundColor(.white)
                    Text("\(latitude)")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                Spacer()
                VStack {
                    Text("Долгота")
                        .font(.caption2)
                        .foregroundColor(.white)
                    Text("\(longitude)")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                Spacer()
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(Color.rosenergo)
            )
        } else {
            Link(destination: settingsURL) {
                HStack {
                    Spacer()
                    VStack {
                        Text("Не разрешен доступ к геопозиции!")
                            .font(.footnote)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                        Text("Нажмите, чтобы перейти в настройки")
                            .font(.caption2)
                            .foregroundColor(.red)
                    }
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
