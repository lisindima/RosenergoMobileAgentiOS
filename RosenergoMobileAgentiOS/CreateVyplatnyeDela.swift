//
//  CreateVyplatnyeDela.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 23.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import CoreLocation
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
    @State private var alertItem: AlertItem?

    private func openCamera() {
        if locationStore.latitude == 0 {
            alertItem = AlertItem(title: "Ошибка", message: "Не удалось определить геопозицию.", action: false)
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

    private func uploadVyplatnyeDela() {
        uploadState = true
        var photos: [PhotoParameters] = []

        for photo in sessionStore.photosURL {
            let photoData = try! Data(contentsOf: photo)
            let file = photoData.base64EncodedString()
            photos.append(PhotoParameters(latitude: locationStore.latitude, longitude: locationStore.longitude, file: file, makedPhotoAt: sessionStore.stringDate()))
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
                alertItem = AlertItem(title: "Успешно", message: "Выплатное дело успешно загружено на сервер.", action: true)
                uploadState = false
            case let .failure(error):
                alertItem = AlertItem(title: "Ошибка", message: "Попробуйте загрузить выплатное дело позже.\n\(error.localizedDescription)", action: false)
                uploadState = false
                print(error)
            }
        }
    }

    var body: some View {
        ScrollView {
            GeoIndicator()
                .padding(.top, 8)
                .padding([.horizontal, .bottom])
            GroupBox {
                CustomInput(text: $numberZayavlenia, name: "Номер заявления")
                CustomInput(text: $insuranceContractNumber, name: "Номер полиса")
            }
            .padding(.horizontal)
            ImageButton(countPhoto: sessionStore.photosURL) {
                openCamera()
            }
            .padding()
        }
        CustomButton(title: "Отправить", subTitle: "на сервер", loading: uploadState, progress: sessionStore.uploadProgress, colorButton: .rosenergo, colorText: .white) {
            if insuranceContractNumber.isEmpty || numberZayavlenia.isEmpty {
                alertItem = AlertItem(title: "Ошибка", message: "Заполните все представленные поля.", action: false)
            } else if sessionStore.photosURL.isEmpty {
                alertItem = AlertItem(title: "Ошибка", message: "Прикрепите хотя бы одну фотографию.", action: false)
            } else {
                uploadVyplatnyeDela()
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
        .navigationTitle("Выплатное дело")
        .alert(item: $alertItem) { error in
            alert(title: error.title, message: error.message, action: error.action)
        }
        .fullScreenCover(isPresented: $showCustomCameraView) {
            CustomCameraView(showRecordVideo: $showRecordVideo)
                .ignoresSafeArea(edges: .vertical)
        }
        .onDisappear { sessionStore.photosURL.removeAll() }
    }
}
