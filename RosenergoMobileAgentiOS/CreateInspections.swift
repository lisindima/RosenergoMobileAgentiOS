//
//  CreateInspections.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 11.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import KeyboardObserving

struct CreateInspections: View {
    
    @EnvironmentObject var sessionStore: SessionStore
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var moc
    
    @ObservedObject var notificationStore: NotificationStore = NotificationStore.shared
    @ObservedObject private var locationStore = LocationStore.shared
    
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
        #if targetEnvironment(simulator)
            showCustomCameraView = true
        #else
        if locationStore.latitude == 0 || locationStore.longitude == 0 {
            sessionStore.alertType = .emptyLocation
            sessionStore.showAlert = true
        } else {
            showCustomCameraView = true
        }
        #endif
    }
    
    private func uploadInspections() {
        sessionStore.uploadInspections(
            carModel: carModel,
            carRegNumber: carRegNumber,
            carBodyNumber: carBodyNumber,
            carVin: carVin,
            insuranceContractNumber: insuranceContractNumber,
            carModel2: carModel2 == "" ? nil : carModel2,
            carRegNumber2: carRegNumber2 == "" ? nil : carRegNumber2,
            carBodyNumber2: carBodyNumber2 == "" ? nil : carBodyNumber2,
            carVin2: carVin2 == "" ? nil : carVin2,
            insuranceContractNumber2: insuranceContractNumber2 == "" ? nil : insuranceContractNumber2,
            latitude: locationStore.latitude,
            longitude: locationStore.longitude,
            photoParameters: sessionStore.photoParameters
        )
    }
    
    private func saveInspections() {
        var localPhotos: [String] = []
        
        for photo in sessionStore.photoParameters {
            localPhotos.append(photo.file)
        }
        
        let id = UUID()
        let localInspections = LocalInspections(context: moc)
        localInspections.latitude = locationStore.latitude
        localInspections.longitude = locationStore.longitude
        localInspections.carBodyNumber = carBodyNumber
        localInspections.carModel = carModel
        localInspections.carRegNumber = carRegNumber
        localInspections.carVin = carVin
        localInspections.insuranceContractNumber = insuranceContractNumber
        localInspections.photos = localPhotos
        localInspections.dateInspections = sessionStore.stringDate()
        localInspections.id = id
        
        if choiseCar == 1 {
            localInspections.carBodyNumber2 = carBodyNumber2
            localInspections.carModel2 = carModel2
            localInspections.carRegNumber2 = carRegNumber2
            localInspections.carVin2 = carVin2
            localInspections.insuranceContractNumber2 = insuranceContractNumber2
        }
        
        try? moc.save()
        sessionStore.alertType = .success
        sessionStore.showAlert = true
        notificationStore.setNotification(id: id.uuidString)
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
                            if choiseCar == 0 {
                                if carModel == "" || carRegNumber == "" || carBodyNumber == "" || carVin == "" || insuranceContractNumber == "" {
                                    sessionStore.alertType = .emptyTextField
                                    sessionStore.showAlert = true
                                } else if sessionStore.photoParameters.isEmpty {
                                    sessionStore.alertType = .emptyPhoto
                                    sessionStore.showAlert = true
                                } else {
                                    uploadInspections()
                                }
                            } else if choiseCar == 1 {
                                if carModel == "" || carRegNumber == "" || carBodyNumber == "" || carVin == "" || insuranceContractNumber == "" || carModel2 == "" || carRegNumber2 == "" || carBodyNumber2 == "" || carVin2 == "" || insuranceContractNumber2 == "" {
                                    sessionStore.alertType = .emptyTextField
                                    sessionStore.showAlert = true
                                } else if sessionStore.photoParameters.isEmpty {
                                    sessionStore.alertType = .emptyPhoto
                                    sessionStore.showAlert = true
                                } else {
                                    uploadInspections()
                                }
                            }
                        }.padding(.trailing, 4)
                        CustomButton(label: "Сохранить", colorButton: Color.rosenergo.opacity(0.2), colorText: .rosenergo) {
                            UIApplication.shared.hideKeyboard()
                            if choiseCar == 0 {
                                if carModel == "" || carRegNumber == "" || carBodyNumber == "" || carVin == "" || insuranceContractNumber == "" {
                                    sessionStore.alertType = .emptyTextField
                                    sessionStore.showAlert = true
                                } else if sessionStore.photoParameters.isEmpty {
                                    sessionStore.alertType = .emptyPhoto
                                    sessionStore.showAlert = true
                                } else {
                                    saveInspections()
                                }
                            } else if choiseCar == 1 {
                                if carModel == "" || carRegNumber == "" || carBodyNumber == "" || carVin == "" || insuranceContractNumber == "" || carModel2 == "" || carRegNumber2 == "" || carBodyNumber2 == "" || carVin2 == "" || insuranceContractNumber2 == "" {
                                    sessionStore.alertType = .emptyTextField
                                    sessionStore.showAlert = true
                                } else if sessionStore.photoParameters.isEmpty {
                                    sessionStore.alertType = .emptyPhoto
                                    sessionStore.showAlert = true
                                } else {
                                    saveInspections()
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
            sessionStore.photoParameters.removeAll()
        }
        .sheet(isPresented: $showCustomCameraView) {
            CustomCameraView()
                .environmentObject(sessionStore)
                .edgesIgnoringSafeArea(.bottom)
        }
        .navigationBarTitle("Новый осмотр")
        .alert(isPresented: $sessionStore.showAlert) {
            switch sessionStore.alertType {
            case .success:
                return Alert(title: Text("Успешно"), message: Text("Осмотр успешно загружен на сервер."), dismissButton: .default(Text("Закрыть"), action: {
                    presentationMode.wrappedValue.dismiss()
                }))
            case .error:
                return Alert(title: Text("Ошибка"), message: Text("Попробуйте загрузить осмотр позже.\n\(sessionStore.errorAlert ?? "")"), dismissButton: .default(Text("Закрыть")))
            case .emptyLocation:
                return Alert(title: Text("Ошибка"), message: Text("Не удалось определить геопозицию."), dismissButton: .default(Text("Закрыть")))
            case .emptyPhoto:
                return Alert(title: Text("Ошибка"), message: Text("Прикрепите хотя бы одну фотографию"), dismissButton: .default(Text("Закрыть")))
            case .emptyTextField:
                return Alert(title: Text("Ошибка"), message: Text("Заполните все представленные пункты."), dismissButton: .default(Text("Закрыть")))
            }
        }
    }
}
