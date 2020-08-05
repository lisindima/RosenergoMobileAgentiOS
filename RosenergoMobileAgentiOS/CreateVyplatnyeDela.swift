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
        #if targetEnvironment(simulator)
        showCustomCameraView = true
        #else
        if locationStore.currentLocation == CLLocation(latitude: 0.0, longitude: 0.0) {
            sessionStore.alertType = .emptyLocation
            sessionStore.showAlert = true
        } else {
            showCustomCameraView = true
        }
        #endif
    }
    
    private func uploadVyplatnyeDela() {
        
        var photoParameters: [PhotoParameters] = []
        
        for photo in sessionStore.photosData {
            let encodedPhoto = photo.base64EncodedString()
            photoParameters.append(PhotoParameters(latitude: locationStore.currentLocation!.coordinate.latitude, longitude: locationStore.currentLocation!.coordinate.longitude, file: encodedPhoto, maked_photo_at: sessionStore.stringDate()))
        }
        
        sessionStore.uploadVyplatnyeDela(
            insuranceContractNumber: insuranceContractNumber,
            numberZayavlenia: numberZayavlenia,
            latitude: locationStore.currentLocation!.coordinate.latitude,
            longitude: locationStore.currentLocation!.coordinate.longitude,
            photos: photoParameters
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
                            sessionStore.alertType = .emptyTextField
                            sessionStore.showAlert = true
                        } else if sessionStore.photosData.isEmpty {
                            sessionStore.alertType = .emptyPhoto
                            sessionStore.showAlert = true
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
        .onDisappear { sessionStore.photosData.removeAll() }
        .fullScreenCover(isPresented: $showCustomCameraView) {
            CustomCameraView(showRecordVideo: $showRecordVideo)
                .environmentObject(sessionStore)
                .environmentObject(locationStore)
                .ignoresSafeArea(edges: .vertical)
        }
        .navigationTitle("Выплатное дело")
        .alert(isPresented: $sessionStore.showAlert) {
            switch sessionStore.alertType {
            case .success:
                return Alert(title: Text("Успешно"), message: Text("Выплатное дело успешно загружено на сервер."), dismissButton: .default(Text("Закрыть"), action: {
                    presentationMode.wrappedValue.dismiss()
                }))
            case .error:
                return Alert(title: Text("Ошибка"), message: Text("Попробуйте загрузить выплатное дело позже."), dismissButton: .default(Text("Закрыть")))
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
