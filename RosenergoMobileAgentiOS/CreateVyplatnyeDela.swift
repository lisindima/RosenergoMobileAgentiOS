//
//  CreateVyplatnyeDela.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 23.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import CoreLocation
import KeyboardObserving

struct CreateVyplatnyeDela: View {
    
    @EnvironmentObject var sessionStore: SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showImagePicker: Bool = false
    @State private var latitude: Double = 0.0
    @State private var longitude: Double = 0.0
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
                VStack {
                    Group {
                        CustomInput(text: $nameCarModel, name: "Марка автомобиля")
                        CustomInput(text: $regCarNumber, name: "Рег. номер автомобиля")
                    }.padding(.horizontal)
                    ImageButton(action: {
                        self.showImagePicker = true
                    }).padding(.horizontal)
                }
            }
            Group {
                if sessionStore.inspectionUploadState == .none {
                    CustomButton(label: "Отправить", colorButton: .rosenergo, colorText: .white) {
                        print("Отправить")
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                } else if sessionStore.inspectionUploadState == .upload {
                    ZStack {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .frame(height: 60)
                                    .cornerRadius(8)
                                    .shadow(radius: 5)
                                    .foregroundColor(Color.rosenergo.opacity(0.2))
                                Rectangle()
                                    .frame(width: (CGFloat(self.sessionStore.uploadProgress) / CGFloat(100.0)) * geometry.size.width, height: 60)
                                    .cornerRadius(8)
                                    .shadow(radius: 5)
                                    .foregroundColor(.rosenergo)
                                    .animation(.linear)
                                HStack {
                                    Spacer()
                                    Text("\(self.sessionStore.uploadProgress) %")
                                        .foregroundColor(.white)
                                        .font(.custom("Futura", size: 24))
                                    Spacer()
                                }
                            }
                        }
                    }
                    .frame(height: 50)
                    .padding(.horizontal)
                }
            }
        }
        .keyboardObserving()
        .onAppear(perform: getLocation)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker()
                .environmentObject(self.sessionStore)
                .edgesIgnoringSafeArea(.bottom)
        }.navigationBarTitle("Выплатные дела")
    }
}
