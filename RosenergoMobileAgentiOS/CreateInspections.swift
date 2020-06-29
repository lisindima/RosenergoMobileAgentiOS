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
    
    @EnvironmentObject private var sessionStore: SessionStore
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var moc
    
    @StateObject private var notificationStore = NotificationStore.shared
    
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
    
    private func uploadInspections() {
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
    
    private func saveInspections() {
        var localPhotos: [String] = []
        
        for photo in self.sessionStore.photoParameters {
            localPhotos.append(photo.file)
        }
        
        let id = UUID()
        let localInspections = LocalInspections(context: self.moc)
        localInspections.latitude = self.sessionStore.latitude
        localInspections.longitude = self.sessionStore.longitude
        localInspections.carBodyNumber = self.carBodyNumber
        localInspections.carModel = self.carModel
        localInspections.carRegNumber = self.carRegNumber
        localInspections.carVin = self.carVin
        localInspections.insuranceContractNumber = self.insuranceContractNumber
        localInspections.photos = localPhotos
        localInspections.dateInspections = self.sessionStore.stringDate
        localInspections.id = id
        
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
        self.notificationStore.setNotification(id: id.uuidString)
    }
    
    var body: some View {
        VStack {
            ScrollView {
                GeoIndicator()
                    .padding(.horizontal)
                Picker("", selection: $choiseCar) {
                    Text("Один автомобиль").tag(0)
                    Text("Два автомобиля").tag(1)
                }
                .labelsHidden()
                .padding(.horizontal)
                .padding(.bottom)
                .pickerStyle(SegmentedPickerStyle())
                VStack(alignment: .leading) {
                    Group {
                        CustomInput(text: $carModel, name: "Марка автомобиля")
                        CustomInput(text: $carRegNumber, name: "Рег. номер автомобиля")
                        CustomInput(text: $carVin, name: "VIN")
                        CustomInput(text: $carBodyNumber, name: "Номер кузова")
                        CustomInput(text: $insuranceContractNumber, name: "Номер полиса")
                    }.padding(.horizontal)
                    ImageButton(action: openCamera, photoParameters: sessionStore.photoParameters)
                        .padding()
                    if choiseCar == 1 {
                        Divider()
                            .padding()
                        Group {
                            CustomInput(text: $carModel2, name: "Марка автомобиля")
                            CustomInput(text: $carRegNumber2, name: "Рег. номер автомобиля")
                            CustomInput(text: $carVin2, name: "VIN")
                            CustomInput(text: $carBodyNumber2, name: "Номер кузова")
                            CustomInput(text: $insuranceContractNumber2, name: "Номер полиса")
                        }.padding(.horizontal)
                        ImageButton(action: openCamera, photoParameters: sessionStore.photoParameters)
                            .padding()
                    }
                }
            }
            Group {
                if sessionStore.uploadState == .none {
                    HStack {
                        CustomButton(label: "Отправить", colorButton: .rosenergo, colorText: .white) {
                            UIApplication.shared.hideKeyboard()
                            if self.choiseCar == 0 {
                                if self.carModel == "" || self.carRegNumber == "" || self.carBodyNumber == "" || self.carVin == "" || self.insuranceContractNumber == "" {
                                    SPAlert.present(title: "Ошибка!", message: "Заполните все представленные пункты.", preset: .error)
                                } else if self.sessionStore.photoParameters.isEmpty {
                                    SPAlert.present(title: "Ошибка!", message: "Прикрепите хотя бы одну фотографию.", preset: .error)
                                } else {
                                    self.uploadInspections()
                                }
                            } else if self.choiseCar == 1 {
                                if self.carModel == "" || self.carRegNumber == "" || self.carBodyNumber == "" || self.carVin == "" || self.insuranceContractNumber == "" || self.carModel2 == "" || self.carRegNumber2 == "" || self.carBodyNumber2 == "" || self.carVin2 == "" || self.insuranceContractNumber2 == "" {
                                    SPAlert.present(title: "Ошибка!", message: "Заполните все представленные пункты.", preset: .error)
                                } else if self.sessionStore.photoParameters.isEmpty {
                                    SPAlert.present(title: "Ошибка!", message: "Прикрепите хотя бы одну фотографию.", preset: .error)
                                } else {
                                    self.uploadInspections()
                                }
                            }
                        }.padding(.trailing, 4)
                        CustomButton(label: "Сохранить", colorButton: Color.rosenergo.opacity(0.2), colorText: .rosenergo) {
                            UIApplication.shared.hideKeyboard()
                            if self.choiseCar == 0 {
                                if self.carModel == "" || self.carRegNumber == "" || self.carBodyNumber == "" || self.carVin == "" || self.insuranceContractNumber == "" {
                                    SPAlert.present(title: "Ошибка!", message: "Заполните все представленные пункты.", preset: .error)
                                } else if self.sessionStore.photoParameters.isEmpty {
                                    SPAlert.present(title: "Ошибка!", message: "Прикрепите хотя бы одну фотографию.", preset: .error)
                                } else {
                                    self.saveInspections()
                                }
                            } else if self.choiseCar == 1 {
                                if self.carModel == "" || self.carRegNumber == "" || self.carBodyNumber == "" || self.carVin == "" || self.insuranceContractNumber == "" || self.carModel2 == "" || self.carRegNumber2 == "" || self.carBodyNumber2 == "" || self.carVin2 == "" || self.insuranceContractNumber2 == "" {
                                    SPAlert.present(title: "Ошибка!", message: "Заполните все представленные пункты.", preset: .error)
                                } else if self.sessionStore.photoParameters.isEmpty {
                                    SPAlert.present(title: "Ошибка!", message: "Прикрепите хотя бы одну фотографию.", preset: .error)
                                } else {
                                    self.saveInspections()
                                }
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
        .onDisappear {
            self.sessionStore.photoParameters.removeAll()
        }
        .fullScreenCover(isPresented: $showCustomCameraView) {
            CustomCameraView()
                .environmentObject(self.sessionStore)
                .edgesIgnoringSafeArea(.vertical)
        }
        .navigationBarTitle("Новый осмотр")
        .alert(isPresented: $sessionStore.showAlert) {
            switch sessionStore.alertType {
            case .success:
                return Alert(title: Text("Успешно!"), message: Text("Осмотр успешно загружен на сервер."), dismissButton: .default(Text("Закрыть")))
            case .error:
                return Alert(title: Text("Ошибка!"), message: Text("Попробуйте загрузить осмотр позже."), dismissButton: .default(Text("Закрыть")))
            }
        }
    }
}
