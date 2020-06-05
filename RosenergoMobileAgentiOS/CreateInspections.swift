//
//  CreateInspections.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 11.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import SPAlert
import KeyboardObserving

struct CreateInspections: View {
    
    @EnvironmentObject var sessionStore: SessionStore
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var moc
    
    @State private var showCustomCameraView: Bool = false
    @State private var choiseCar: Int = 0
    @State private var carModel: String = ""
    @State private var carModel2: String = ""
    @State private var carVin: String = ""
    @State private var carVin2: String = ""
    @State private var carBodyNumber: String = ""
    @State private var carBodyNumber2: String = ""
    @State private var carRegNumber: String = ""
    @State private var carRegNumber2: String = ""
    @State private var insuranceContractNumber: String = ""
    @State private var insuranceContractNumber2: String = ""
    
    func openCamera() {
        if sessionStore.latitude == 0 || sessionStore.longitude == 0 {
            SPAlert.present(title: "Ошибка!", message: "Не удалось определить геопозицию", preset: .error)
        } else {
            showCustomCameraView = true
        }
    }
    
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
                Picker("", selection: $choiseCar) {
                    Text("Один автомобиль").tag(0)
                    Text("Два автомобиля").tag(1)
                }
                .labelsHidden()
                .padding(.horizontal)
                .padding(.bottom, 4)
                .pickerStyle(SegmentedPickerStyle())
                VStack(alignment: .leading) {
                    Text("Первый автомобиль")
                        .fontWeight(.bold)
                        .padding(.leading)
                    Text("Введите данные о первом автомобиле")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.leading)
                    Group {
                        CustomInput(text: $carModel, name: "Марка автомобиля")
                        CustomInput(text: $carRegNumber, name: "Рег. номер автомобиля")
                        CustomInput(text: $carVin, name: "VIN")
                        CustomInput(text: $carBodyNumber, name: "Номер кузова")
                        CustomInput(text: $insuranceContractNumber, name: "Номер полиса")
                    }.padding(.horizontal)
                    ImageButton(action: openCamera)
                        .padding()
                    if choiseCar == 1 {
                        Divider()
                            .padding()
                        Text("Второй автомобиль")
                            .fontWeight(.bold)
                            .padding(.leading)
                        Text("Введите данные о втором автомобиле")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .padding(.leading)
                        Group {
                            CustomInput(text: $carModel2, name: "Марка автомобиля")
                            CustomInput(text: $carRegNumber2, name: "Рег. номер автомобиля")
                            CustomInput(text: $carVin2, name: "VIN")
                            CustomInput(text: $carBodyNumber2, name: "Номер кузова")
                            CustomInput(text: $insuranceContractNumber2, name: "Номер полиса")
                        }.padding(.horizontal)
                        ImageButton(action: openCamera)
                            .padding()
                    }
                }
            }
            Group {
                if sessionStore.uploadState == .none {
                    HStack {
                        CustomButton(label: "Отправить", colorButton: .rosenergo, colorText: .white) {
                            if self.carModel == "" || self.carRegNumber == "" || self.carBodyNumber == "" || self.carVin == "" || self.insuranceContractNumber == "" {
                                SPAlert.present(title: "Ошибка!", message: "Заполните все представленные пункты.", preset: .error)
                            } else {
                                self.sessionStore.uploadInspections(
                                    carModel: self.carModel,
                                    carRegNumber: self.carRegNumber,
                                    carBodyNumber: self.carBodyNumber,
                                    carVin: self.carVin,
                                    insuranceContractNumber: self.insuranceContractNumber,
                                    carModel2: self.carModel2 == "" ? nil : self.carModel2,
                                    carRegNumber2: self.carRegNumber2 == "" ? nil : self.carRegNumber2,
                                    carBodyNumber2: self.carBodyNumber2 == "" ? nil : self.carBodyNumber2,
                                    carVin2: self.carVin2 == "" ? nil : self.carVin2,
                                    insuranceContractNumber2: self.insuranceContractNumber2 == "" ? nil : self.insuranceContractNumber2,
                                    latitude: self.sessionStore.latitude,
                                    longitude: self.sessionStore.longitude,
                                    photoParameters: self.sessionStore.photoParameters
                                )
                            }
                        }.padding(.trailing, 4)
                        CustomButton(label: "Сохранить", colorButton: Color.rosenergo.opacity(0.2), colorText: .rosenergo) {
                            if self.carModel == "" || self.carRegNumber == "" || self.carBodyNumber == "" || self.carVin == "" || self.insuranceContractNumber == "" {
                                SPAlert.present(title: "Ошибка!", message: "Заполните все представленные пункты.", preset: .error)
                            } else {
                                let localInspections = LocalInspections(context: self.moc)
                                localInspections.latitude = self.sessionStore.latitude
                                localInspections.longitude = self.sessionStore.longitude
                                localInspections.carBodyNumber = self.carBodyNumber
                                localInspections.carModel = self.carModel
                                localInspections.carRegNumber = self.carRegNumber
                                localInspections.carVin = self.carVin
                                localInspections.insuranceContractNumber = self.insuranceContractNumber
                                localInspections.photos = self.sessionStore.imageLocalInspections
                                localInspections.dateInspections = self.sessionStore.stringDate
                                localInspections.id = UUID()
                                if self.choiseCar == 1 {
                                    localInspections.carBodyNumber2 = self.carBodyNumber2
                                    localInspections.carModel2 = self.carModel2
                                    localInspections.carRegNumber2 = self.carRegNumber2
                                    localInspections.carVin2 = self.carVin2
                                    localInspections.insuranceContractNumber2 = self.insuranceContractNumber2
                                }
                                try? self.moc.save()
                                self.presentationMode.wrappedValue.dismiss()
                                SPAlert.present(title: "Успешно!", message: "Осмотр успешно сохранен на устройстве.", preset: .done)
                            }
                        }.padding(.leading, 4)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                } else if sessionStore.uploadState == .upload {
                    UploadIndicator(progress: $sessionStore.uploadProgress, color: .rosenergo)
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
        .sheet(isPresented: $showCustomCameraView) {
            CustomCameraView()
                .environmentObject(self.sessionStore)
                .edgesIgnoringSafeArea(.bottom)
        }.navigationBarTitle("Новый осмотр")
    }
}
