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
    
    @State private var vinAndNumberBody: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var choiseCar: Int = 0
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
                    ImageButton(action: {
                        self.showImagePicker = true
                    }).padding(.horizontal)
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
                        Button(action: {
                            self.showImagePicker = true
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.rosenergo)
                                    .opacity(0.2)
                                    .frame(minWidth: nil, idealWidth: nil, maxWidth: .infinity, minHeight: 70, idealHeight: 70, maxHeight: 70)
                                HStack {
                                    Image(systemName: "camera")
                                        .font(.largeTitle)
                                        .foregroundColor(.rosenergo)
                                    Text("\(sessionStore.photoParameters.count) выбрано фотографий")
                                }
                            }
                        }.padding(.horizontal)
                    }
                }
            }
            Group {
                if sessionStore.inspectionUploadState == .none {
                    HStack {
                        CustomButton(label: "Отправить", colorButton: .rosenergo, colorText: .white) {
                            self.sessionStore.uploadInspections(carModel: self.nameCarModel, carRegNumber: self.regCarNumber, carBodyNumber: self.numberBody, carVin: self.vin, insuranceContractNumber: self.numberPolis, latitude: self.sessionStore.latitude, longitude: self.sessionStore.longitude, photoParameters: self.sessionStore.photoParameters)
                        }.padding(.trailing, 4)
                        CustomButton(label: "Сохранить", colorButton: Color.rosenergo.opacity(0.2), colorText: .rosenergo) {
                            let localInspections = LocalInspections(context: self.moc)
                            localInspections.latitude = self.sessionStore.latitude
                            localInspections.longitude = self.sessionStore.longitude
                            localInspections.carBodyNumber = self.numberBody
                            localInspections.carModel = self.nameCarModel
                            localInspections.carRegNumber = self.regCarNumber
                            localInspections.carVin = self.vin
                            localInspections.insuranceContractNumber = self.numberPolis
                            localInspections.photos = self.sessionStore.imageLocalInspections
                            localInspections.dateInspections = self.sessionStore.stringDate
                            localInspections.id = UUID()
                            if self.choiseCar == 1 {
                                localInspections.carBodyNumber2 = self.numberBody2
                                localInspections.carModel2 = self.nameCarModel2
                                localInspections.carRegNumber2 = self.regCarNumber2
                                localInspections.carVin2 = self.vin2
                                localInspections.insuranceContractNumber2 = self.numberPolis2
                            }
                            try? self.moc.save()
                            self.presentationMode.wrappedValue.dismiss()
                            SPAlert.present(title: "Успешно!", message: "Осмотр успешно сохранен на устройстве.", preset: .done)
                        }.padding(.leading, 4)
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
                                    Text("\(self.sessionStore.uploadProgress * 100) %")
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
        .onAppear(perform: sessionStore.getLocation)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker()
                .environmentObject(self.sessionStore)
                .edgesIgnoringSafeArea(.bottom)
        }.navigationBarTitle("Новый осмотр")
    }
}
