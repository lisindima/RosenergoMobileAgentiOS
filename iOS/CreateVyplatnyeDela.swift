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
    @State private var showVyplatnyedelaDetails: Bool = false
    @State private var insuranceContractNumber: String = ""
    @State private var numberZayavlenia: String = ""
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
        
        sessionStore.upload(.uploadVyplatnyedela, parameters: VyplatnyeDelaParameters(
            insuranceContractNumber: insuranceContractNumber,
            numberZayavlenia: numberZayavlenia,
            latitude: locationStore.latitude,
            longitude: locationStore.longitude,
            photos: photos
        )) { [self] (result: Result<Vyplatnyedela, ApiError>) in
            switch result {
            case let .success(value):
                vyplatnyedelaItem = value
                showVyplatnyedelaDetails = true
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
            GeoIndicator()
                .padding(.top, 8)
                .padding([.horizontal, .bottom])
            GroupBox {
                CustomInput("Номер заявления", text: $numberZayavlenia)
                CustomInput("Номер полиса", text: $insuranceContractNumber)
            }
            .padding(.horizontal)
            ImageButton(countPhoto: photosURL, action: openCamera)
                .padding()
                .fullScreenCover(isPresented: $showCustomCameraView) {
                    CustomCameraView(showRecordVideo: $showRecordVideo, photosURL: $photosURL, videoURL: $videoURL)
                        .ignoresSafeArea(edges: .vertical)
                }
        }
        CustomButton("Отправить", titleUpload: "Загрузка выплатного дела", loading: uploadState, progress: sessionStore.uploadProgress) {
            validateInput { uploadVyplatnyeDela() }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
        .navigationTitle("Выплатное дело")
        .customAlert(item: $alertItem)
        .sheet(isPresented: $showVyplatnyedelaDetails, onDismiss: { presentationMode.wrappedValue.dismiss() }) {
            if let vyplatnyedela = vyplatnyedelaItem {
                NavigationView {
                    VyplatnyedelaDetails(vyplatnyedela: vyplatnyedela)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button(action: { showVyplatnyedelaDetails = false }) {
                                    Text("Закрыть")
                                }
                            }
                        }
                }
            }
        }
    }
}
