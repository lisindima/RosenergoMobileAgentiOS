//
//  CreateVyplatnyeDela.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 23.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import CoreLocation

struct CreateVyplatnyeDela: View {
    
    @EnvironmentObject private var sessionStore: SessionStore
    @EnvironmentObject private var locationStore: LocationStore
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var showRecordVideo: Bool = false
    @State private var showCustomCameraView: Bool = false
    @State private var insuranceContractNumber: String = ""
    @State private var numberZayavlenia: String = ""
    
    func openCamera() {
        if locationStore.latitude == 0 {
            sessionStore.alertError = AlertError(title: "Ошибка", message: "Не удалось определить геопозицию.", action: false)
        } else {
            showCustomCameraView = true
        }
    }
    
    private func alert(title: String, message: String, action: Bool) -> Alert {
        Alert(
            title: Text(title),
            message: Text(message),
            dismissButton: action ? .default(Text("Закрыть"), action: { presentationMode.wrappedValue.dismiss() }) : .default(Text("Закрыть"))
        )
    }
    
    private func uploadVyplatnyeDela() {
        
        var photos: [PhotoParameters] = []
        
        for photo in sessionStore.photosData {
            let encodedPhoto = photo.base64EncodedString()
            photos.append(PhotoParameters(latitude: locationStore.latitude, longitude: locationStore.longitude, file: encodedPhoto, maked_photo_at: sessionStore.stringDate()))
        }
        
        sessionStore.uploadVyplatnyeDela(
            parameters: VyplatnyeDelaParameters(
                insurance_contract_number: insuranceContractNumber,
                number_zayavlenia: numberZayavlenia,
                latitude: locationStore.latitude,
                longitude: locationStore.longitude,
                photos: photos
            )
        )
    }
    
    var body: some View {
        VStack {
            ScrollView {
                GeoIndicator()
                    .padding(.top, 8)
                    .padding([.horizontal, .bottom])
                VStack {
                    GroupBox {
                        CustomInput(text: $numberZayavlenia, name: "Номер заявления")
                        CustomInput(text: $insuranceContractNumber, name: "Номер полиса")
                    }.padding(.horizontal)
                    ImageButton(action: openCamera, countPhoto: sessionStore.photosData)
                        .padding()
                }
            }
            Group {
                if sessionStore.uploadState == .none {
                    CustomButton(label: "Отправить", colorButton: .rosenergo, colorText: .white) {
                        if insuranceContractNumber == "" || numberZayavlenia == "" {
                            sessionStore.alertError = AlertError(title: "Ошибка", message: "Заполните все представленные поля.", action: false)
                        } else if sessionStore.photosData.isEmpty {
                            sessionStore.alertError = AlertError(title: "Ошибка", message: "Прикрепите хотя бы одну фотографию.", action: false)
                        } else {
                            uploadVyplatnyeDela()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                } else if sessionStore.uploadState == .upload {
                    UploadIndicator(progress: $sessionStore.uploadProgress)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                }
            }
        }
        .navigationTitle("Выплатное дело")
        .alert(item: $sessionStore.alertError) { error in
            alert(title: error.title, message: error.message, action: error.action)
        }
        .fullScreenCover(isPresented: $showCustomCameraView) {
            CustomCameraView(showRecordVideo: $showRecordVideo)
                .ignoresSafeArea(edges: .vertical)
        }
        .onDisappear { sessionStore.photosData.removeAll() }
    }
}
