//
//  CreateInspections.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 11.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import CoreData
import KeyboardObserving

struct CreateInspections: View {
    
    @EnvironmentObject private var sessionStore: SessionStore
    @EnvironmentObject private var notificationStore: NotificationStore
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
    @State private var vinAndNumber: Bool = false
    @State private var vinAndNumber2: Bool = false
    @State private var indexSeries: Int?
    @State private var indexSeries2: Int?
    
    var insuranceContractSeries: [String] = ["ХХХ", "CCC", "РРР", "ННН", "МММ", "ККК", "ЕЕЕ", "ВВВ"]
    
    func openCamera() {
        if sessionStore.latitude == 0 || sessionStore.longitude == 0 {
            sessionStore.alertType = .emptyLocation
            sessionStore.showAlert = true
        } else {
            showCustomCameraView = true
        }
    }
    
    private func uploadInspections() {
        sessionStore.uploadInspections(
            carModel: carModel,
            carRegNumber: carRegNumber,
            carBodyNumber: vinAndNumber ? carVin : carBodyNumber,
            carVin: carVin,
            insuranceContractNumber: insuranceContractSeries[indexSeries!] + insuranceContractNumber,
            carModel2: carModel2 == "" ? nil : carModel2,
            carRegNumber2: carRegNumber2 == "" ? nil : carRegNumber2,
            carBodyNumber2: vinAndNumber2 ? (carVin2 == "" ? nil : carVin2) : (carBodyNumber2 == "" ? nil : carBodyNumber2),
            carVin2: carVin2 == "" ? nil : carVin2,
            insuranceContractNumber2: insuranceContractSeries[indexSeries2!] + insuranceContractNumber2 == "" ? nil : insuranceContractSeries[indexSeries2!] + insuranceContractNumber2,
            latitude: sessionStore.latitude,
            longitude: sessionStore.longitude,
            photoParameters: sessionStore.photoParameters,
            localUpload: false,
            localInspections: nil
        )
    }
    
    private func saveInspections() {
        
        let id = UUID()
        let localInspections = LocalInspections(context: moc)
        localInspections.latitude = sessionStore.latitude
        localInspections.longitude = sessionStore.longitude
        localInspections.carBodyNumber = vinAndNumber ? carVin : carBodyNumber
        localInspections.carModel = carModel
        localInspections.carRegNumber = carRegNumber
        localInspections.carVin = carVin
        localInspections.insuranceContractNumber = insuranceContractSeries[indexSeries!] + insuranceContractNumber
        localInspections.dateInspections = sessionStore.stringDate()
        localInspections.id = id
        
        var localPhotos: [LocalPhotos] = []
        var setPhotoId: Int16 = 0
        
        for photo in sessionStore.photosData {
            setPhotoId += 1
            let photos = NSEntityDescription.insertNewObject(forEntityName: "LocalPhotos", into: moc) as! LocalPhotos
            photos.id = setPhotoId
            photos.photosData = photo
            localPhotos.append(photos)
        }
        
        localInspections.localPhotos = Set(localPhotos)
        
        if choiseCar == 1 {
            localInspections.carBodyNumber2 = vinAndNumber2 ? carVin2 : carBodyNumber2
            localInspections.carModel2 = carModel2
            localInspections.carRegNumber2 = carRegNumber2
            localInspections.carVin2 = carVin2
            localInspections.insuranceContractNumber2 = insuranceContractSeries[indexSeries2!] + insuranceContractNumber2
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
                VStack {
                    Group {
                        GroupBox(label:
                            HStack {
                                Image(systemName: "doc.plaintext")
                                    .imageScale(.large)
                                    .foregroundColor(.rosenergo)
                                Text("Страховой полис")
                            }
                        ) {
                            HStack {
                                CustomPicker("Серия", data: insuranceContractSeries, selectionIndex: $indexSeries)
                                    .modifier(InputModifier())
                                    .frame(width: 100)
                                CustomInput(text: $insuranceContractNumber, name: "Номер")
                                    .keyboardType(.numberPad)
                            }
                        }
                        GroupBox {
                            CustomInput(text: $carModel, name: "Марка автомобиля")
                            CustomInput(text: $carRegNumber, name: "Рег. номер автомобиля")
                        }
                        GroupBox(label:
                            Toggle(isOn: $vinAndNumber, label: {
                                Image(systemName: "doc.text.magnifyingglass")
                                    .imageScale(.large)
                                    .foregroundColor(.rosenergo)
                                Text("Совпадают?")
                            })
                        ) {
                            CustomInput(text: $carVin, name: "VIN")
                            CustomInput(text: vinAndNumber ? $carVin : $carBodyNumber, name: "Номер кузова")
                                .disabled(vinAndNumber)
                        }
                    }.padding(.horizontal)
                    ImageButton(action: openCamera, photoParameters: sessionStore.photoParameters)
                        .padding()
                    if choiseCar == 1 {
                        Divider()
                            .padding([.horizontal, .bottom])
                        Group {
                            GroupBox(label:
                                HStack {
                                    Image(systemName: "doc.plaintext")
                                        .imageScale(.large)
                                        .foregroundColor(.rosenergo)
                                    Text("Страховой полис")
                                }
                            ) {
                                HStack {
                                    CustomPicker("Серия", data: insuranceContractSeries, selectionIndex: $indexSeries2)
                                        .modifier(InputModifier())
                                        .frame(width: 100)
                                    CustomInput(text: $insuranceContractNumber2, name: "Номер")
                                        .keyboardType(.numberPad)
                                }
                            }
                            GroupBox {
                                CustomInput(text: $carModel2, name: "Марка автомобиля")
                                CustomInput(text: $carRegNumber2, name: "Рег. номер автомобиля")
                            }
                            GroupBox(label:
                                Toggle(isOn: $vinAndNumber2, label: {
                                    Image(systemName: "doc.text.magnifyingglass")
                                        .imageScale(.large)
                                        .foregroundColor(.rosenergo)
                                    Text("Совпадают?")
                                })
                            ) {
                                CustomInput(text: $carVin2, name: "VIN")
                                CustomInput(text: vinAndNumber2 ? $carVin2 : $carBodyNumber2, name: "Номер кузова")
                                    .disabled(vinAndNumber2)
                            }
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
                            if choiseCar == 0 {
                                if carModel == "" || carRegNumber == "" || carBodyNumber == "" || carVin == "" || insuranceContractNumber == "" || indexSeries == nil {
                                    sessionStore.alertType = .emptyTextField
                                    sessionStore.showAlert = true
                                } else if sessionStore.photoParameters.isEmpty {
                                    sessionStore.alertType = .emptyPhoto
                                    sessionStore.showAlert = true
                                } else {
                                    uploadInspections()
                                }
                            } else if choiseCar == 1 {
                                if carModel == "" || carRegNumber == "" || carBodyNumber == "" || carVin == "" || insuranceContractNumber == "" || indexSeries == nil || carModel2 == "" || carRegNumber2 == "" || carBodyNumber2 == "" || carVin2 == "" || insuranceContractNumber2 == "" || indexSeries2 == nil {
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
                            if choiseCar == 0 {
                                if carModel == "" || carRegNumber == "" || carBodyNumber == "" || carVin == "" || insuranceContractNumber == "" || indexSeries == nil {
                                    sessionStore.alertType = .emptyTextField
                                    sessionStore.showAlert = true
                                } else if sessionStore.photosData.isEmpty {
                                    sessionStore.alertType = .emptyPhoto
                                    sessionStore.showAlert = true
                                } else {
                                    saveInspections()
                                }
                            } else if choiseCar == 1 {
                                if carModel == "" || carRegNumber == "" || carBodyNumber == "" || carVin == "" || insuranceContractNumber == "" || indexSeries == nil || carModel2 == "" || carRegNumber2 == "" || carBodyNumber2 == "" || carVin2 == "" || insuranceContractNumber2 == "" || indexSeries2 == nil {
                                    sessionStore.alertType = .emptyTextField
                                    sessionStore.showAlert = true
                                } else if sessionStore.photosData.isEmpty {
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
        .onDisappear { sessionStore.photosData.removeAll() }
        .fullScreenCover(isPresented: $showCustomCameraView) {
            CustomCameraView()
                .environmentObject(sessionStore)
                .edgesIgnoringSafeArea(.vertical)
        }
        .navigationTitle("Новый осмотр")
        .alert(isPresented: $sessionStore.showAlert) {
            switch sessionStore.alertType {
            case .success:
                return Alert(title: Text("Успешно"), message: Text("Осмотр успешно загружен на сервер."), dismissButton: .default(Text("Закрыть"), action: {
                    presentationMode.wrappedValue.dismiss()
                }))
            case .error:
                return Alert(title: Text("Ошибка"), message: Text("Попробуйте загрузить осмотр позже."), dismissButton: .default(Text("Закрыть")))
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
