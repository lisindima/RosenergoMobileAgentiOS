//
//  CreateInspections.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 11.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import CoreData
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
    @State private var alertItem: AlertItem?

    private func openCamera() {
        if locationStore.latitude == 0 {
            alertItem = AlertItem(title: "Ошибка", message: "Не удалось определить геопозицию.")
            playHaptic(.error)
        } else {
            showCustomCameraView = true
        }
    }

    private func validateInput(upload: Bool) {
        switch choiceCar {
        case 0:
            if carModel.isEmpty || carRegNumber.isEmpty || carBodyNumber.isEmpty || carVin.isEmpty || insuranceContractNumber.isEmpty {
                alertItem = AlertItem(title: "Ошибка", message: "Заполните все представленные поля.")
                playHaptic(.error)
            } else if sessionStore.photosURL.isEmpty {
                alertItem = AlertItem(title: "Ошибка", message: "Прикрепите хотя бы одну фотографию.")
                playHaptic(.error)
            } else {
                if upload {
                    uploadInspections()
                } else {
                    saveInspections()
                }
            }
        case 1:
            if carModel.isEmpty || carRegNumber.isEmpty || carBodyNumber.isEmpty || carVin.isEmpty || insuranceContractNumber.isEmpty || carModel2.isEmpty || carRegNumber2.isEmpty || carBodyNumber2.isEmpty || carVin2.isEmpty || insuranceContractNumber2.isEmpty {
                alertItem = AlertItem(title: "Ошибка", message: "Заполните все представленные поля.")
                playHaptic(.error)
            } else if sessionStore.photosURL.isEmpty {
                alertItem = AlertItem(title: "Ошибка", message: "Прикрепите хотя бы одну фотографию.")
                playHaptic(.error)
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

        for photo in sessionStore.photosURL {
            let photoData = try! Data(contentsOf: photo)
            let encodedPhoto = photoData.base64EncodedString()
            photos.append(PhotoParameters(latitude: locationStore.latitude, longitude: locationStore.longitude, file: encodedPhoto, makedPhotoAt: sessionStore.stringDate()))
        }

        if sessionStore.videoURL != nil {
            do {
                let videoData = try Data(contentsOf: sessionStore.videoURL!)
                video = videoData.base64EncodedString()
            } catch {
                print(error)
            }
        }

        sessionStore.upload("testinspection", parameters: InspectionParameters(
            carModel: carModel,
            carRegNumber: carRegNumber,
            carBodyNumber: vinAndNumber ? carVin : carBodyNumber,
            carVin: carVin,
            insuranceContractNumber: choiseSeries.rawValue + insuranceContractNumber,
            carModel2: carModel2,
            carRegNumber2: carRegNumber2,
            carBodyNumber2: vinAndNumber2 ? carVin2 : carBodyNumber2,
            carVin2: carVin2,
            insuranceContractNumber2: insuranceContractNumber2.isEmpty ? nil : choiseSeries2.rawValue + insuranceContractNumber2,
            latitude: locationStore.latitude,
            longitude: locationStore.longitude,
            video: video,
            photos: photos
        )) { response in
            switch response {
            case .success:
                alertItem = AlertItem(title: "Успешно", message: "Осмотр успешно загружен на сервер.") { presentationMode.wrappedValue.dismiss() }
                playHaptic(.success)
                uploadState = false
            case let .failure(error):
                alertItem = AlertItem(title: "Ошибка", message: "Попробуйте загрузить осмотр позже.\n\(error.localizedDescription)")
                playHaptic(.error)
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

        for photo in sessionStore.photosURL {
            setPhotoId += 1
            let photos = NSEntityDescription.insertNewObject(forEntityName: "LocalPhotos", into: moc) as! LocalPhotos
            let photoData = try! Data(contentsOf: photo)
            photos.id = setPhotoId
            photos.photosData = photoData
            localPhotos.append(photos)
        }

        localInspections.localPhotos = Set(localPhotos)

        do {
            try moc.save()
            alertItem = AlertItem(title: "Успешно", message: "Осмотр успешно сохранен на устройстве.") { presentationMode.wrappedValue.dismiss() }
            playHaptic(.success)
            notificationStore.setNotification(id: id.uuidString)
        } catch {
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
            alertItem = AlertItem(title: "Ошибка", message: "Произошла неизвестная ошибка: \(nsError), \(nsError.userInfo)")
            playHaptic(.error)
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
            ImageButton(countPhoto: sessionStore.photosURL) {
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
                ImageButton(countPhoto: sessionStore.photosURL) {
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
        .customAlert($alertItem)
        .fullScreenCover(isPresented: $showCustomCameraView) {
            CustomCameraView(showRecordVideo: $showRecordVideo)
                .ignoresSafeArea(edges: .vertical)
        }
        .onDisappear { sessionStore.photosURL.removeAll() }
    }
}
