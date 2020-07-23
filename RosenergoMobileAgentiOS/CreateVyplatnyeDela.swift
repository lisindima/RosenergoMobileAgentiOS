//
//  CreateVyplatnyeDela.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 23.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct CreateVyplatnyeDela: View {
    
    @EnvironmentObject var sessionStore: SessionStore
    @EnvironmentObject var locationStore: LocationStore
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showCustomCameraView: Bool = false
    @State private var insuranceContractNumber: String = ""
    @State private var numberZayavlenia: String = ""
    
    func openCamera() {
        #if targetEnvironment(simulator)
        showCustomCameraView = true
        #else
        if locationStore.currentLocation?.coordinate.latitude == 0 || locationStore.currentLocation?.coordinate.longitude == 0 {
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
                        CustomInput(text: $insuranceContractNumber, name: "Номер полиса")
                        CustomInput(text: $numberZayavlenia, name: "Номер заявления")
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
                    .ignoresSafeArea(.keyboard)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                } else if sessionStore.uploadState == .upload {
                    UploadIndicator(progress: $sessionStore.uploadProgress, color: .rosenergo)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                }
            }
        }
        .onDisappear { sessionStore.photosData.removeAll() }
        .fullScreenCover(isPresented: $showCustomCameraView) {
            CustomCameraView()
                .environmentObject(sessionStore)
                .environmentObject(locationStore)
                .ignoresSafeArea(edges: .vertical)
        }
        .navigationTitle("Выплатные дела")
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
