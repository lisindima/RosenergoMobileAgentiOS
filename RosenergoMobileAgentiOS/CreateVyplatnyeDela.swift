//
//  CreateVyplatnyeDela.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 23.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import CoreLocation
import KeyboardObserving

struct CreateVyplatnyeDela: View {
    
    @EnvironmentObject var sessionStore: SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showCustomCameraView: Bool = false
    @State private var insuranceContractNumber: String = ""
    @State private var numberZayavlenia: String = ""
    
    func openCamera() {
        #if targetEnvironment(simulator)
            showCustomCameraView = true
        #else
        if sessionStore.latitude == 0 || sessionStore.longitude == 0 {
            sessionStore.alertType = .emptyLocation
            sessionStore.showAlert = true
        } else {
            showCustomCameraView = true
        }
        #endif
    }
    
    var body: some View {
        VStack {
            ScrollView {
                GeoIndicator()
                    .padding(.horizontal)
                    .padding(.bottom)
                VStack {
                    Group {
                        CustomInput(text: $insuranceContractNumber, name: "Номер полиса")
                        CustomInput(text: $numberZayavlenia, name: "Номер заявления")
                    }.padding(.horizontal)
                    ImageButton(action: openCamera, photoParameters: sessionStore.photoParameters)
                        .padding()
                }
            }
            Group {
                if sessionStore.uploadState == .none {
                    CustomButton(label: "Отправить", colorButton: .rosenergo, colorText: .white) {
                        UIApplication.shared.hideKeyboard()
                        if self.insuranceContractNumber == "" || self.numberZayavlenia == "" {
                            self.sessionStore.alertType = .emptyTextField
                            self.sessionStore.showAlert = true
                        } else if self.sessionStore.photoParameters.isEmpty {
                            self.sessionStore.alertType = .emptyPhoto
                            self.sessionStore.showAlert = true
                        } else {
                            self.sessionStore.uploadVyplatnyeDela(
                                insuranceContractNumber: self.insuranceContractNumber,
                                numberZayavlenia: self.numberZayavlenia,
                                latitude: self.sessionStore.latitude,
                                longitude: self.sessionStore.longitude,
                                photos: self.sessionStore.photoParameters
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                } else if sessionStore.uploadState == .upload {
                    UploadIndicator(progress: $sessionStore.uploadProgress, color: .rosenergo)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                }
            }
        }
        .keyboardObserving()
        .onAppear(perform: sessionStore.getLocation)
        .onDisappear {
            self.sessionStore.photoParameters.removeAll()
        }
        .sheet(isPresented: $showCustomCameraView) {
            CustomCameraView()
                .environmentObject(self.sessionStore)
                .edgesIgnoringSafeArea(.bottom)
        }
        .navigationBarTitle("Выплатное дело")
        .alert(isPresented: $sessionStore.showAlert) {
            switch sessionStore.alertType {
            case .success:
                return Alert(title: Text("Успешно"), message: Text("Выплатное дело успешно загружено на сервер."), dismissButton: .default(Text("Закрыть"), action: {
                    self.presentationMode.wrappedValue.dismiss()
                }))
            case .error:
                return Alert(title: Text("Ошибка"), message: Text("Попробуйте загрузить выплатное дело позже."), dismissButton: .default(Text("Закрыть")))
            case .emptyLocation:
                return Alert(title: Text("Ошибка"), message: Text("Не удалось определить геопозицию."), dismissButton: .default(Text("Закрыть")))
            case .emptyPhoto:
                return Alert(title: Text("Ошибка"), message: Text("Прикрепите хотя бы одну фотографию"), dismissButton: .default(Text("Закрыть")))
            case .emptyTextField:
                return Alert(title: Text("Ошибка"), message: Text("Заполните все представленные поля."), dismissButton: .default(Text("Закрыть")))
            }
        }
    }
}
