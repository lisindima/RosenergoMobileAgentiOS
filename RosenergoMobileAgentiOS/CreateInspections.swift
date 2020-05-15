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
    
    @EnvironmentObject var sessionStore: SessionStore
    
    @State private var showImagePicker: Bool = false
    @State private var choiseCar: Int = 0
    @State private var latitude: Double = 0.0
    @State private var longitude: Double = 0.0
    @State private var vin: String = ""
    @State private var numberBody: String = ""
    @State private var numberPolis: String = ""
    @State private var nameCarModel: String = ""
    @State private var regCarNumber: String = ""
    
    var locationManager = CLLocationManager()
    
    func getLocation() {
        locationManager.requestWhenInUseAuthorization()
        var currentLoc: CLLocation!
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == .authorizedAlways {
            currentLoc = locationManager.location
            latitude = currentLoc.coordinate.latitude
            longitude = currentLoc.coordinate.longitude
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Широта: \(latitude)")
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(Color.red.opacity(0.2))
                )
                Spacer()
                Text("Долгота: \(longitude)")
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(Color.red.opacity(0.2))
                )
            }.padding(.horizontal)
            CustomInput(text: $nameCarModel, name: "Марка автомобиля")
                .padding(.horizontal)
            CustomInput(text: $regCarNumber, name: "Рег. номер автомобиля")
                .padding(.horizontal)
            CustomInput(text: $vin, name: "VIN")
                .padding(.horizontal)
            CustomInput(text: $numberBody, name: "Номер кузова")
                .padding(.horizontal)
            CustomInput(text: $numberPolis, name: "Номер полиса")
                .padding([.horizontal, .bottom])
            HStack {
                ImageButton(action: {
                    self.showImagePicker = true
                })
                ImageButton(action: {
                    self.showImagePicker = true
                })
                ImageButton(action: {
                    self.showImagePicker = true
                })
            }.padding(.horizontal)
            HStack {
                ImageButton(action: {
                    self.showImagePicker = true
                })
                ImageButton(action: {
                    self.showImagePicker = true
                })
                ImageButton(action: {
                    self.showImagePicker = true
                })
            }.padding(.horizontal)
            Spacer()
            CustomButton(label: "Отправить на сервер", colorButton: .rosenergo) {
                self.sessionStore.uploadInspections(apiToken: self.sessionStore.loginModel!.data.apiToken)
            }.padding()
        }
        .onAppear(perform: getLocation)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker()
                .edgesIgnoringSafeArea(.bottom)
        }.navigationBarTitle("Новый осмотр")
    }
}
