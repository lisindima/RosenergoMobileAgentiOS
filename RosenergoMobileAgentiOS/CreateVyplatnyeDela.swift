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
    @State private var insuranceContractNumber: String = ""
    @State private var numberZayavlenia: String = ""
    
    var body: some View {
        VStack {
            ScrollView {
                HStack {
                    Text("Широта: \(sessionStore.latitude)")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                        .padding(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundColor(Color.red.opacity(0.2))
                    )
                    Spacer()
                    Text("Долгота: \(sessionStore.longitude)")
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
                        CustomInput(text: $insuranceContractNumber, name: "Номер полиса")
                        CustomInput(text: $numberZayavlenia, name: "Номер заявления")
                    }.padding(.horizontal)
                    ImageButton(action: {
                        self.showImagePicker = true
                    }).padding(.horizontal)
                }
            }
            Group {
                if sessionStore.uploadState == .none {
                    CustomButton(label: "Отправить", colorButton: .rosenergo, colorText: .white) {
                        self.sessionStore.uploadVyplatnyeDela(
                            insuranceContractNumber: self.insuranceContractNumber,
                            numberZayavlenia: self.numberZayavlenia,
                            latitude: self.sessionStore.latitude,
                            longitude: self.sessionStore.longitude,
                            photos: self.sessionStore.photoParameters
                        )
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                } else if sessionStore.uploadState == .upload {
                    HStack {
                        Spacer()
                        ActivityIndicatorButton()
                        Spacer()
                    }
                    .padding()
                    .background(Color.rosenergo)
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
            }
        }
        .keyboardObserving()
        .onAppear(perform: sessionStore.getLocation)
        .onDisappear {
            self.sessionStore.photoParameters.removeAll()
            self.sessionStore.imageLocalInspections.removeAll()
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker()
                .environmentObject(self.sessionStore)
                .edgesIgnoringSafeArea(.bottom)
        }.navigationBarTitle("Выплатные дела")
    }
}
