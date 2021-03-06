//
//  CreateVyplatnyeDela.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 23.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct CreateVyplatnyeDela: View {
    @EnvironmentObject private var sessionStore: SessionStore
    @EnvironmentObject private var locationStore: LocationStore
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var videoURL: URL?
    @State private var photosURL: [URL] = []
    @State private var uploadState: Bool = false
    @State private var showRecordVideo: Bool = false
    @State private var showCustomCameraView: Bool = false
    @State private var insuranceContractNumber: String = ""
    @State private var numberZayavlenia: String = ""
    @State private var choiseSeries: Series = .XXX
    @State private var alertItem: AlertItem?
    @State private var vyplatnyedelaItem: Vyplatnyedela?
    
    private func openCamera() {
        if locationStore.latitude == 0 {
            alertItem = AlertItem(title: "Ошибка", message: "Не удалось определить геопозицию.")
        } else {
            showCustomCameraView = true
        }
    }
    
    private func validateInput(completion: @escaping () -> Void) {
        if insuranceContractNumber.isEmpty || numberZayavlenia.isEmpty {
            alertItem = AlertItem(title: "Ошибка", message: "Заполните все представленные поля.")
        } else if photosURL.isEmpty {
            alertItem = AlertItem(title: "Ошибка", message: "Прикрепите хотя бы одну фотографию.")
        } else {
            completion()
        }
    }
    
    private func uploadVyplatnyeDela() {
        uploadState = true
        var photos: [PhotoParameters] = []
        
        for photo in photosURL {
            let file = try! Data(contentsOf: photo)
            photos.append(PhotoParameters(latitude: locationStore.latitude, longitude: locationStore.longitude, file: file, makedPhotoAt: Date()))
        }
        
        Endpoint.api.upload(.uploadVyplatnyedela, parameters: VyplatnyeDelaParameters(
            insuranceContractNumber: choiseSeries.rawValue + insuranceContractNumber,
            numberZayavlenia: numberZayavlenia,
            latitude: locationStore.latitude,
            longitude: locationStore.longitude,
            photos: photos
        )) { [self] (result: Result<Vyplatnyedela, ApiError>) in
            switch result {
            case let .success(value):
                vyplatnyedelaItem = value
                uploadState = false
            case let .failure(error):
                alertItem = AlertItem(title: "Ошибка", message: "Попробуйте загрузить выплатное дело позже.\n\(error.localizedDescription)")
                uploadState = false
                debugPrint(error)
            }
        }
    }
    
    var body: some View {
        ScrollView {
            Group {
                GeoIndicator(
                    latitude: locationStore.latitude,
                    longitude: locationStore.longitude
                )
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
                    CustomInput("Номер заявления", text: $numberZayavlenia)
                }
                ImageButton(countPhoto: photosURL, action: openCamera)
                    .padding(.top)
                    .fullScreenCover(isPresented: $showCustomCameraView) {
                        CustomCameraView(showRecordVideo: $showRecordVideo, photosURL: $photosURL, videoURL: $videoURL)
                            .ignoresSafeArea(edges: .vertical)
                    }
            }.padding(.horizontal)
        }
        CustomButton("Отправить", loading: uploadState) {
            validateInput { uploadVyplatnyeDela() }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
        .navigationTitle("Выплатное дело")
        .customAlert(item: $alertItem)
        .sheet(item: $vyplatnyedelaItem, onDismiss: { presentationMode.wrappedValue.dismiss() }) { vyplatnyedela in
            NavigationView {
                VyplatnyedelaDetails(vyplatnyedela: vyplatnyedela)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button(action: { vyplatnyedelaItem = nil }) {
                                Text("Закрыть")
                            }
                        }
                    }
            }
        }
    }
}
