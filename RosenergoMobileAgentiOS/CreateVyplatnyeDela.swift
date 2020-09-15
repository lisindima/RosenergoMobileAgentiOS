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
    
    @State private var uploadState: Bool = false
    @State private var showRecordVideo: Bool = false
    @State private var showCustomCameraView: Bool = false
    @State private var insuranceContractNumber: String = ""
    @State private var numberZayavlenia: String = ""
    @State private var alertItem: AlertItem? = nil
    
    private func openCamera() {
        if locationStore.latitude == 0 {
            alertItem = AlertItem(title: "Ошибка", message: "Не удалось определить геопозицию.")
            playHaptic(.error)
        } else {
            showCustomCameraView = true
        }
    }
    
    private func uploadVyplatnyeDela() {
        uploadState = true
        var photos: [PhotoParameters] = []
        
        for photo in sessionStore.photosURL {
            let photoData = try! Data(contentsOf: photo)
            let file = photoData.base64EncodedString()
            photos.append(PhotoParameters(latitude: locationStore.latitude, longitude: locationStore.longitude, file: file, makedPhotoAt: stringDate()))
        }
        
        sessionStore.upload("vyplatnyedela", parameters: VyplatnyeDelaParameters(
            insuranceContractNumber: insuranceContractNumber,
            numberZayavlenia: numberZayavlenia,
            latitude: locationStore.latitude,
            longitude: locationStore.longitude,
            photos: photos
        )) { response in
            switch response {
            case .success:
                alertItem = AlertItem(title: "Успешно", message: "Выплатное дело успешно загружено на сервер.") { presentationMode.wrappedValue.dismiss() }
                playHaptic(.success)
                uploadState = false
            case let .failure(error):
                alertItem = AlertItem(title: "Ошибка", message: "Попробуйте загрузить выплатное дело позже.\n\(error.localizedDescription)")
                playHaptic(.error)
                uploadState = false
                log(error.localizedDescription)
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
            ImageButton(countPhoto: sessionStore.photosURL) {
                openCamera()
            }
            .padding()
        }
        CustomButton("Отправить", subTitle: "на сервер", loading: uploadState, progress: sessionStore.uploadProgress) {
            if insuranceContractNumber.isEmpty || numberZayavlenia.isEmpty {
                alertItem = AlertItem(title: "Ошибка", message: "Заполните все представленные поля.")
                playHaptic(.error)
            } else if sessionStore.photosURL.isEmpty {
                alertItem = AlertItem(title: "Ошибка", message: "Прикрепите хотя бы одну фотографию.")
                playHaptic(.error)
            } else {
                uploadVyplatnyeDela()
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
        .navigationTitle("Выплатное дело")
        .customAlert($alertItem)
        .fullScreenCover(isPresented: $showCustomCameraView) {
            CustomCameraView(showRecordVideo: $showRecordVideo)
                .ignoresSafeArea(edges: .vertical)
        }
        .onDisappear { sessionStore.photosURL.removeAll() }
    }
}
