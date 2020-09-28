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
    
    @State private var photosURL: [URL] = []
    @State private var videoURL: URL? = nil
    @State private var uploadState: Bool = false
    @State private var showRecordVideo: Bool = false
    @State private var showCustomCameraView: Bool = false
    @State private var showInspectionDetails: Bool = false
    @State private var car: Car = .oneCar
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
    @State private var alertItem: AlertItem? = nil
    @State private var inspectionItem: Inspections? = nil
    
    private func openCamera() {
        if locationStore.latitude == 0 {
            alertItem = AlertItem(title: "Ошибка", message: "Не удалось определить геопозицию.")
        } else {
            showCustomCameraView = true
        }
    }
    
    private func validateInput(completion: @escaping () -> Void) {
        if car == .oneCar
            ? (carModel.isEmpty || carRegNumber.isEmpty || carBodyNumber.isEmpty || carVin.isEmpty || insuranceContractNumber.isEmpty)
            : (carModel.isEmpty || carRegNumber.isEmpty || carBodyNumber.isEmpty || carVin.isEmpty || insuranceContractNumber.isEmpty || carModel2.isEmpty || carRegNumber2.isEmpty || carBodyNumber2.isEmpty || carVin2.isEmpty || insuranceContractNumber2.isEmpty)
        {
            alertItem = AlertItem(title: "Ошибка", message: "Заполните все представленные поля.")
        } else if photosURL.isEmpty {
            alertItem = AlertItem(title: "Ошибка", message: "Прикрепите хотя бы одну фотографию.")
        } else {
            completion()
        }
    }
    
    private func uploadInspections() {
        uploadState = true
        var photos: [PhotoParameters] = []
        var video: Data?
        
        for photo in photosURL {
            let file = try! Data(contentsOf: photo)
            photos.append(PhotoParameters(latitude: locationStore.latitude, longitude: locationStore.longitude, file: file, makedPhotoAt: Date()))
        }
        
        if let videoURL = videoURL {
            do {
                video = try Data(contentsOf: videoURL)
            } catch {
                log(error.localizedDescription)
            }
        }
        
        sessionStore.upload(.uploadInspection, parameters: InspectionParameters(
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
        )) { [self] (result: Result<Inspections, UploadError>) in
            switch result {
            case let .success(value):
                inspectionItem = value
                showInspectionDetails = true
                uploadState = false
            case let .failure(error):
                alertItem = AlertItem(title: "Ошибка", message: "Попробуйте загрузить осмотр позже.\n\(error.localizedDescription)")
                uploadState = false
                log(error.localizedDescription)
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
        localInspections.dateInspections = Date()
        localInspections.videoURL = videoURL
        
        if car == .twoCar {
            localInspections.carBodyNumber2 = vinAndNumber2 ? carVin2 : carBodyNumber2
            localInspections.carModel2 = carModel2
            localInspections.carRegNumber2 = carRegNumber2
            localInspections.carVin2 = carVin2
            localInspections.insuranceContractNumber2 = choiseSeries2.rawValue + insuranceContractNumber2
        }
        
        var localPhotos: [LocalPhotos] = []
        var setPhotoId: Int16 = 1
        
        for photo in photosURL {
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
            notificationStore.setNotification(id: id.uuidString)
        } catch {
            log("Unresolved error \(error)")
            alertItem = AlertItem(title: "Ошибка", message: "Произошла неизвестная ошибка: \(error)")
        }
    }
    
    private func toggle(_ isOn: Binding<Bool>, label: String = "Совпадают?", systemImage: String = "doc.text.magnifyingglass") -> some View {
        Toggle(isOn: isOn, label: { Label(label, systemImage: systemImage) })
            .toggleStyle(SwitchToggleStyle(tint: .rosenergo))
    }
    
    var body: some View {
        ScrollView {
            Group {
                GeoIndicator()
                    .padding(.top, 8)
                    .padding(.bottom)
                GroupBox(label: Label("Страховой полис", systemImage: "doc.plaintext")) {
                    HStack {
                        SeriesPicker(selectedSeries: $choiseSeries)
                            .modifier(InputModifier())
                        CustomInput("Номер", text: $insuranceContractNumber)
                            .keyboardType(.numberPad)
                    }
                }
                GroupBox {
                    CustomInput("Марка автомобиля", text: $carModel)
                    CustomInput("Рег. номер автомобиля", text: $carRegNumber)
                }
                GroupBox(label: toggle($vinAndNumber)) {
                    CustomInput("VIN", text: $carVin)
                    CustomInput("Номер кузова", text: vinAndNumber ? $carVin : $carBodyNumber)
                        .disabled(vinAndNumber)
                }
                if car == .twoCar {
                    Divider()
                        .padding(.vertical)
                    GroupBox(label: Label("Страховой полис", systemImage: "doc.plaintext")) {
                        HStack {
                            SeriesPicker(selectedSeries: $choiseSeries2)
                                .modifier(InputModifier())
                            CustomInput("Номер", text: $insuranceContractNumber2)
                                .keyboardType(.numberPad)
                        }
                    }
                    GroupBox {
                        CustomInput("Марка автомобиля", text: $carModel2)
                        CustomInput("Рег. номер автомобиля", text: $carRegNumber2)
                    }
                    GroupBox(label: toggle($vinAndNumber2)) {
                        CustomInput("VIN", text: $carVin2)
                        CustomInput("Номер кузова", text: vinAndNumber2 ? $carVin2 : $carBodyNumber2)
                            .disabled(vinAndNumber2)
                    }
                }
                ImageButton(countPhoto: photosURL, action: openCamera)
                    .padding(.vertical)
                    .fullScreenCover(isPresented: $showCustomCameraView) {
                        CustomCameraView(showRecordVideo: $showRecordVideo, photosURL: $photosURL, videoURL: $videoURL)
                            .ignoresSafeArea(edges: .vertical)
                    }
            }.padding(.horizontal)
        }
        HStack {
            CustomButton("Отправить", titleUpload: "Загрузка осмотра", loading: uploadState, progress: sessionStore.uploadProgress) {
                validateInput { uploadInspections() }
            }
            if !uploadState {
                CustomButton("Сохранить", colorButton: Color.rosenergo.opacity(0.2), colorText: .rosenergo) {
                    validateInput { saveInspections() }
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
        .navigationTitle("Новый осмотр")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Picker("", selection: $car) {
                    Image(systemName: "car")
                        .tag(Car.oneCar)
                    Image(systemName: "car.2")
                        .tag(Car.twoCar)
                }
                .labelsHidden()
                .pickerStyle(InlinePickerStyle())
            }
        }
        .customAlert(item: $alertItem)
        .sheet(isPresented: $showInspectionDetails, onDismiss: { presentationMode.wrappedValue.dismiss() }) {
            if let inspection = inspectionItem {
                NavigationView {
                    InspectionsDetails(inspection: inspection)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button(action: { showInspectionDetails = false }) {
                                    Text("Закрыть")
                                }
                            }
                        }
                }
            }
        }
    }
}
