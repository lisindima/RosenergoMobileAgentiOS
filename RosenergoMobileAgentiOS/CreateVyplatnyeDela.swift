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
    
    @State private var videoURL: URL? = nil
    @State private var photosURL: [URL] = []
    @State private var uploadState: Bool = false
    @State private var showRecordVideo: Bool = false
    @State private var showCustomCameraView: Bool = false
    @State private var insuranceContractNumber: String = ""
    @State private var numberZayavlenia: String = ""
    @State private var alertItem: AlertItem? = nil
    
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
        )) { [self] (result: Result<Vyplatnyedela, UploadError>) in
            switch result {
            case .success:
                alertItem = AlertItem(title: "Успешно", message: "Выплатное дело успешно загружено на сервер.") { presentationMode.wrappedValue.dismiss() }
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
        }
        CustomButton("Отправить", titleUpload: "Загрузка выплатного дела", loading: uploadState, progress: sessionStore.uploadProgress) {
            validateInput { uploadVyplatnyeDela() }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
        .navigationTitle("Выплатное дело")
        .customAlert($alertItem)
        .fullScreenCover(isPresented: $showCustomCameraView) {
            CustomCameraView(showRecordVideo: $showRecordVideo, photosURL: $photosURL, videoURL: $videoURL)
                .ignoresSafeArea(edges: .vertical)
        }
    }
}
