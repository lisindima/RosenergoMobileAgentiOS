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
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var moc
    
    @State private var showImagePicker: Bool = false
    @State private var choiseCar: Int = 0
    @State private var latitude: Double = 0.0
    @State private var longitude: Double = 0.0
    @State private var vin: String = ""
    @State private var numberBody: String = ""
    @State private var numberPolis: String = ""
    @State private var nameCarModel: String = ""
    @State private var regCarNumber: String = ""
    @State private var vin2: String = ""
    @State private var numberBody2: String = ""
    @State private var numberPolis2: String = ""
    @State private var nameCarModel2: String = ""
    @State private var regCarNumber2: String = ""
    
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
        ScrollView {
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
            Picker(selection: $choiseCar, label: Text("")) {
                Text("Один автомобиль").tag(0)
                Text("Два автомобиля").tag(1)
            }
            .labelsHidden()
            .padding(.horizontal)
            .padding(.bottom, 4)
            .pickerStyle(SegmentedPickerStyle())
            VStack {
                Group {
                    CustomInput(text: $nameCarModel, name: "Марка автомобиля")
                    CustomInput(text: $regCarNumber, name: "Рег. номер автомобиля")
                    CustomInput(text: $vin, name: "VIN")
                    CustomInput(text: $numberBody, name: "Номер кузова")
                    CustomInput(text: $numberPolis, name: "Номер полиса")
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
                if choiseCar == 1 {
                    Divider()
                        .padding()
                    Group {
                        CustomInput(text: $nameCarModel2, name: "Марка автомобиля")
                        CustomInput(text: $regCarNumber2, name: "Рег. номер автомобиля")
                        CustomInput(text: $vin2, name: "VIN")
                        CustomInput(text: $numberBody2, name: "Номер кузова")
                        CustomInput(text: $numberPolis2, name: "Номер полиса")
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
                }
                Spacer()
                HStack {
                    CustomButton(label: "Отправить", colorButton: .rosenergo, colorText: .white) {
                        self.sessionStore.uploadInspections(apiToken: self.sessionStore.loginModel!.data.apiToken)
                    }.padding(.trailing, 4)
                    CustomButton(label: "Сохранить", colorButton: Color.rosenergo.opacity(0.2), colorText: .rosenergo) {
                        let localInspections = LocalInspections(context: self.moc)
                        localInspections.latitude = self.latitude
                        localInspections.longitude = self.longitude
                        localInspections.carBodyNumber = self.numberBody
                        localInspections.carModel = self.nameCarModel
                        localInspections.carRegNumber = self.regCarNumber
                        localInspections.carVin = self.vin
                        localInspections.insuranceContractNumber = self.numberPolis
                        localInspections.photos = self.sessionStore.imageLocalInspections
                        localInspections.id = UUID()
                        try? self.moc.save()
                        self.presentationMode.wrappedValue.dismiss()
                    }.padding(.leading, 4)
                }.padding(.horizontal)
            }
        }
        .onAppear(perform: getLocation)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker()
                .environmentObject(self.sessionStore)
                .edgesIgnoringSafeArea(.bottom)
        }.navigationBarTitle("Новый осмотр")
    }
}
