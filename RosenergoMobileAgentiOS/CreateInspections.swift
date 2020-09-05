//
//  CreateInspections.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 11.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import CoreData
import CoreLocation
import SwiftUI

struct CreateInspections: View {
    @EnvironmentObject private var sessionStore: SessionStore
    @EnvironmentObject private var locationStore: LocationStore
    @EnvironmentObject private var notificationStore: NotificationStore
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.managedObjectContext) private var moc

    @State private var uploadState: Bool = false
    @State private var showRecordVideo: Bool = true
    @State private var showCustomCameraView: Bool = false
    @State private var choiceCar: Int = 0
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
    @State private var choiseSeries: Series = .XXX
    @State private var choiseSeries2: Series = .XXX

    private func openCamera() {
        if locationStore.latitude == 0 {
            sessionStore.alertItem = AlertItem(title: "Ошибка", message: "Не удалось определить геопозицию.", action: false)
        } else {
            showCustomCameraView = true
        }
    }

    private func alert(title: String, message: String, action: Bool) -> Alert {
        Alert(
            title: Text(title),
            message: Text(message),
            dismissButton: action ? .default(Text("Закрыть"), action: { presentationMode.wrappedValue.dismiss() }) : .cancel()
        )
    }

    private func validateInput(upload: Bool) {
        switch choiceCar {
        case 0:
            if carModel.isEmpty || carRegNumber.isEmpty || carBodyNumber.isEmpty || carVin.isEmpty || insuranceContractNumber.isEmpty {
                sessionStore.alertItem = AlertItem(title: "Ошибка", message: "Заполните все представленные поля.", action: false)
            } else if sessionStore.photosData.isEmpty {
                sessionStore.alertItem = AlertItem(title: "Ошибка", message: "Прикрепите хотя бы одну фотографию.", action: false)
            } else {
                if upload {
                    uploadInspections()
                } else {
                    saveInspections()
                }
            }
        case 1:
            if carModel.isEmpty || carRegNumber.isEmpty || carBodyNumber.isEmpty || carVin.isEmpty || insuranceContractNumber.isEmpty || carModel2.isEmpty || carRegNumber2.isEmpty || carBodyNumber2.isEmpty || carVin2.isEmpty || insuranceContractNumber2.isEmpty {
                sessionStore.alertItem = AlertItem(title: "Ошибка", message: "Заполните все представленные поля.", action: false)
            } else if sessionStore.photosData.isEmpty {
                sessionStore.alertItem = AlertItem(title: "Ошибка", message: "Прикрепите хотя бы одну фотографию.", action: false)
            } else {
                if upload {
                    uploadInspections()
                } else {
                    saveInspections()
                }
            }
        default:
            print("ОЙ")
        }
    }

    private func uploadInspections() {
        uploadState = true
        var photos: [PhotoParameters] = []
        var video: String?

        for photo in sessionStore.photosData {
            let encodedPhoto = photo.base64EncodedString()
            photos.append(PhotoParameters(latitude: locationStore.latitude, longitude: locationStore.longitude, file: encodedPhoto, maked_photo_at: sessionStore.stringDate()))
        }

        if sessionStore.videoURL != nil {
            do {
                let videoData = try Data(contentsOf: URL(string: sessionStore.videoURL!)!)
                video = videoData.base64EncodedString()
            } catch {
                print(error)
            }
        }

        sessionStore.upload("testinspection", parameters: InspectionParameters(
            car_model: carModel,
            car_reg_number: carRegNumber,
            car_body_number: vinAndNumber ? carVin : carBodyNumber,
            car_vin: carVin,
            insurance_contract_number: choiseSeries.rawValue + insuranceContractNumber,
            car_model2: carModel2,
            car_reg_number2: carRegNumber2,
            car_body_number2: vinAndNumber2 ? carVin2 : carBodyNumber2,
            car_vin2: carVin2,
            insurance_contract_number2: insuranceContractNumber2.isEmpty ? nil : choiseSeries2.rawValue + insuranceContractNumber2,
            latitude: locationStore.latitude,
            longitude: locationStore.longitude,
            video: video,
            photos: photos
        )) { response in
            switch response {
            case .success:
                sessionStore.alertItem = AlertItem(title: "Успешно", message: "Осмотр успешно загружен на сервер.", action: true)
                uploadState = false
            case let .failure(error):
                sessionStore.alertItem = AlertItem(title: "Ошибка", message: "Попробуйте загрузить осмотр позже.\n\(error.localizedDescription)", action: false)
                uploadState = false
                print(error)
            }
        }
    }

    private func saveInspections() {
        let id = UUID()
        let localInspections = LocalInspections(context: moc)
        localInspections.id = id
        localInspections.latitude = locationStore.latitude
        localInspections.longitude = locationStore.longitude
        localInspections.carBodyNumber = vinAndNumber ? carVin : carBodyNumber
        localInspections.carModel = carModel
        localInspections.carRegNumber = carRegNumber
        localInspections.carVin = carVin
        localInspections.insuranceContractNumber = choiseSeries.rawValue + insuranceContractNumber
        localInspections.dateInspections = sessionStore.stringDate()
        localInspections.videoURL = sessionStore.videoURL

        if choiceCar == 1 {
            localInspections.carBodyNumber2 = vinAndNumber2 ? carVin2 : carBodyNumber2
            localInspections.carModel2 = carModel2
            localInspections.carRegNumber2 = carRegNumber2
            localInspections.carVin2 = carVin2
            localInspections.insuranceContractNumber2 = choiseSeries2.rawValue + insuranceContractNumber2
        }

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

        do {
            try moc.save()
            sessionStore.alertItem = AlertItem(title: "Успешно", message: "Осмотр успешно сохранен на устройстве.", action: true)
            notificationStore.setNotification(id: id.uuidString)
        } catch {
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
            sessionStore.alertItem = AlertItem(title: "Ошибка", message: "Произошла неизвестная ошибка: \(nsError), \(nsError.userInfo)", action: false)
        }
    }

    var body: some View {
        ScrollView {
            GeoIndicator()
                .padding(.top, 8)
                .padding([.horizontal, .bottom])
            GroupBox(label:
                Label("Страховой полис", systemImage: "doc.plaintext")
            ) {
                HStack {
                    SeriesPicker(selectedSeries: $choiseSeries)
                        .modifier(InputModifier())
                    CustomInput(text: $insuranceContractNumber, name: "Номер")
                        .keyboardType(.numberPad)
                }
            }
            .padding(.horizontal)
            GroupBox {
                CustomInput(text: $carModel, name: "Марка автомобиля")
                CustomInput(text: $carRegNumber, name: "Рег. номер автомобиля")
            }
            .padding(.horizontal)
            GroupBox(label:
                Toggle(isOn: $vinAndNumber, label: {
                    Label("Совпадают?", systemImage: "doc.text.magnifyingglass")
                }).toggleStyle(SwitchToggleStyle(tint: .rosenergo))
            ) {
                CustomInput(text: $carVin, name: "VIN")
                CustomInput(text: vinAndNumber ? $carVin : $carBodyNumber, name: "Номер кузова")
                    .disabled(vinAndNumber)
            }
            .padding(.horizontal)
            ImageButton(countPhoto: sessionStore.photosData) {
                openCamera()
            }
            .padding()
            if choiceCar == 1 {
                Divider()
                    .padding([.horizontal, .bottom])
                GroupBox(label:
                    Label("Страховой полис", systemImage: "doc.plaintext")
                ) {
                    HStack {
                        SeriesPicker(selectedSeries: $choiseSeries2)
                            .modifier(InputModifier())
                        CustomInput(text: $insuranceContractNumber2, name: "Номер")
                            .keyboardType(.numberPad)
                    }
                }
                .padding(.horizontal)
                GroupBox {
                    CustomInput(text: $carModel2, name: "Марка автомобиля")
                    CustomInput(text: $carRegNumber2, name: "Рег. номер автомобиля")
                }
                .padding(.horizontal)
                GroupBox(label:
                    Toggle(isOn: $vinAndNumber2, label: {
                        Label("Совпадают?", systemImage: "doc.text.magnifyingglass")
                    }).toggleStyle(SwitchToggleStyle(tint: .rosenergo))
                ) {
                    CustomInput(text: $carVin2, name: "VIN")
                    CustomInput(text: vinAndNumber2 ? $carVin2 : $carBodyNumber2, name: "Номер кузова")
                        .disabled(vinAndNumber2)
                }
                .padding(.horizontal)
                ImageButton(countPhoto: sessionStore.photosData) {
                    openCamera()
                }
                .padding()
            }
        }
        HStack {
            CustomButton(title: "Отправить", subTitle: "на сервер", loading: uploadState, progress: sessionStore.uploadProgress, colorButton: .rosenergo, colorText: .white) {
                validateInput(upload: true)
            }
            if !uploadState {
                CustomButton(title: "Сохранить", subTitle: "на устройство", colorButton: Color.rosenergo.opacity(0.2), colorText: .rosenergo) {
                    validateInput(upload: false)
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
        .navigationTitle("Новый осмотр")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Picker("", selection: $choiceCar) {
                    Image(systemName: "car")
                        .tag(0)
                    Image(systemName: "car.2")
                        .tag(1)
                }
                .labelsHidden()
                .pickerStyle(InlinePickerStyle())
            }
        }
        .alert(item: $sessionStore.alertItem) { error in
            alert(title: error.title, message: error.message, action: error.action)
        }
        .fullScreenCover(isPresented: $showCustomCameraView) {
            CustomCameraView(showRecordVideo: $showRecordVideo)
                .ignoresSafeArea(edges: .vertical)
        }
        .onDisappear { sessionStore.photosData.removeAll() }
    }
}
