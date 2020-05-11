//
//  CreateInspections.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 11.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import CoreLocation

struct CreateInspections: View {
    
    @State private var latitude: Double = 0.0
    @State private var longitude: Double = 0.0
    @State private var vin: String = ""
    @State private var numberBody: String = ""
    @State private var numberPolis: String = ""
    
    var locationManager = CLLocationManager()
    
    func getLocation() {
        locationManager.requestWhenInUseAuthorization()
        var currentLoc: CLLocation!
        if (CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == .authorizedAlways) {
            currentLoc = locationManager.location
            latitude = currentLoc.coordinate.latitude
            longitude = currentLoc.coordinate.longitude
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Широта: \(latitude)")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                    Spacer()
                    Text("Долгота: \(longitude)")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }.padding(.horizontal, 20)
                CustomInput(text: $numberPolis, name: "Номер полиса")
                    .padding(.horizontal)
                CustomInput(text: $vin, name: "VIN")
                    .padding(.horizontal)
                CustomInput(text: $numberBody, name: "Номер кузова")
                    .padding(.horizontal)
                Spacer()
            }
            .navigationBarTitle("Новый осмотр")
            .onAppear(perform: getLocation)
        }
    }
}

struct CreateInspections_Previews: PreviewProvider {
    static var previews: some View {
        CreateInspections()
    }
}
