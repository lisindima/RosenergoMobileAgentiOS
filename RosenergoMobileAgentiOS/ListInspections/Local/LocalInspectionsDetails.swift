//
//  LocalInspectionsDetails.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 23.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct LocalInspectionsDetails: View {
    
    @EnvironmentObject private var sessionStore: SessionStore
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode
    #if !os(watchOS)
    @EnvironmentObject private var notificationStore: NotificationStore
    #endif
    @State private var presentMapActionSheet: Bool = false
    @State private var yandexGeoState: YandexGeoState = .loading
    @State private var yandexGeo: YandexGeo?
    
    var localInspections: LocalInspections
    
    private func delete() {
        #if !os(watchOS)
        notificationStore.cancelNotifications(id: localInspections.id!.uuidString)
        #endif
        presentationMode.wrappedValue.dismiss()
        moc.delete(localInspections)
        do {
            try moc.save()
        } catch {
            print(error)
        }
    }
    
    private func uploadLocalInspections() {
        sessionStore.uploadInspections(
            carModel: localInspections.carModel!,
            carRegNumber: localInspections.carRegNumber!,
            carBodyNumber: localInspections.carBodyNumber!,
            carVin: localInspections.carVin!,
            insuranceContractNumber: localInspections.insuranceContractNumber!,
            carModel2: localInspections.carModel2,
            carRegNumber2: localInspections.carRegNumber2,
            carBodyNumber2: localInspections.carBodyNumber2,
            carVin2: localInspections.carVin2,
            insuranceContractNumber2: localInspections.insuranceContractNumber2,
            latitude: localInspections.latitude,
            longitude: localInspections.longitude,
            photoParameters: nil,
            uploadType: .local,
            localInspections: localInspections
        )
    }
    
    var size: Double {
        #if os(watchOS)
        return 75.0
        #else
        return 100.0
        #endif
    }
    
    var body: some View {
        #if os(watchOS)
        details
            .edgesIgnoringSafeArea(.bottom)
        #else
        details
            .environment(\.horizontalSizeClass, .regular)
            .navigationBarItems(trailing:
                MenuRepresentable()
            )
        #endif
    }
    
    var details: some View {
        VStack {
            Form {
                if localInspections.photos != nil {
                    Section(header: Text("Фотографии").fontWeight(.bold)) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(localInspections.photos!, id: \.self) { photo in
                                    NavigationLink(destination: LocalImageDetail(photos: localInspections.photos!)) {
                                        Image(uiImage: UIImage(data: Data(base64Encoded: photo, options: .ignoreUnknownCharacters)!)!.resizedImage(width: CGFloat(size), height: CGFloat(size)))
                                            .resizable()
                                            .frame(width: CGFloat(size), height: CGFloat(size))
                                            .cornerRadius(10)
                                    }.buttonStyle(PlainButtonStyle())
                                }
                            }.padding(.vertical, 8)
                        }
                    }
                }
                if localInspections.dateInspections != nil {
                    Section(header: Text("Дата осмотра").fontWeight(.bold)) {
                        SectionItem(
                            imageName: "timer",
                            imageColor: .rosenergo,
                            subTitle: "Дата создания осмотра",
                            title: localInspections.dateInspections!.dataInspection(local: true)
                        )
                    }
                }
                if localInspections.carModel != nil {
                    Section(header: Text(localInspections.carModel2 != nil ? "Первый автомобиль" : "Информация").fontWeight(.bold)) {
                        SectionItem(
                            imageName: "text.justify",
                            imageColor: .rosenergo,
                            subTitle: "Страховой полис",
                            title: localInspections.insuranceContractNumber!
                        )
                        SectionItem(
                            imageName: "car",
                            imageColor: .rosenergo,
                            subTitle: "Модель автомобиля",
                            title: localInspections.carModel!
                        )
                        SectionItem(
                            imageName: "rectangle",
                            imageColor: .rosenergo,
                            subTitle: "Регистрационный номер",
                            title: localInspections.carRegNumber!
                        )
                        SectionItem(
                            imageName: "v.circle",
                            imageColor: .rosenergo,
                            subTitle: "VIN",
                            title: localInspections.carVin!
                        )
                        SectionItem(
                            imageName: "textformat.123",
                            imageColor: .rosenergo,
                            subTitle: "Номер кузова",
                            title: localInspections.carBodyNumber!
                        )
                    }
                }
                if localInspections.carModel2 != nil {
                    Section(header: Text("Второй автомобиль").fontWeight(.bold)) {
                        SectionItem(
                            imageName: "text.justify",
                            imageColor: .rosenergo,
                            subTitle: "Страховой полис",
                            title: localInspections.insuranceContractNumber2!
                        )
                        SectionItem(
                            imageName: "car",
                            imageColor: .rosenergo,
                            subTitle: "Модель автомобиля",
                            title: localInspections.carModel2!
                        )
                        SectionItem(
                            imageName: "rectangle",
                            imageColor: .rosenergo,
                            subTitle: "Регистрационный номер",
                            title: localInspections.carRegNumber2!
                        )
                        SectionItem(
                            imageName: "v.circle",
                            imageColor: .rosenergo,
                            subTitle: "VIN",
                            title: localInspections.carVin2!
                        )
                        SectionItem(
                            imageName: "textformat.123",
                            imageColor: .rosenergo,
                            subTitle: "Номер кузова",
                            title: localInspections.carBodyNumber2!
                        )
                    }
                }
                Section(header: Text("Место проведения осмотра").fontWeight(.bold)) {
                    Button(action: {
                        presentMapActionSheet = true
                    }) {
                        if yandexGeoState == .success && yandexGeo?.response.geoObjectCollection.featureMember.first?.geoObject.metaDataProperty.geocoderMetaData.text != nil {
                            SectionItem(
                                imageName: "map",
                                imageColor: .rosenergo,
                                subTitle: "Адрес места проведения осмотра",
                                title: yandexGeo!.response.geoObjectCollection.featureMember.first!.geoObject.metaDataProperty.geocoderMetaData.text!
                            )
                        } else if yandexGeoState == .failure {
                            SectionItem(
                                imageName: "exclamationmark.triangle",
                                imageColor: .yellow,
                                subTitle: "Ошибка, не удалось определить адрес",
                                title: "Проверьте подключение к интернету!"
                            )
                        } else if yandexGeoState == .loading {
                            HStack {
                                ProgressView()
                                    .frame(width: 24)
                                VStack(alignment: .leading) {
                                    Text("Определяем адрес осмотра")
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                    Text("Загрузка")
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                    }
                }
            }
            if sessionStore.uploadState == .none {
                #if os(iOS)
                CustomButton(label: "Отправить на сервер", colorButton: .rosenergo, colorText: .white) {
                    uploadLocalInspections()
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                #else
                Button("Отправить") {
                    uploadLocalInspections()
                }.padding(.bottom, 8)
                #endif
            } else if sessionStore.uploadState == .upload {
                #if os(iOS)
                UploadIndicator(progress: $sessionStore.uploadProgress, color: .rosenergo)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                #else
                ProgressView()
                #endif
            }
        }
        .navigationTitle("Не отправлено")
        .actionSheet(isPresented: $presentMapActionSheet) {
            ActionSheet(title: Text("Выберите приложение"), message: Text("В каком приложение вы хотите открыть это местоположение?"), buttons: [
                .default(Text("Apple Maps")) {
                    #if !os(watchOS)
                    UIApplication.shared.open(URL(string: "https://maps.apple.com/?daddr=\(localInspections.latitude),\(localInspections.longitude)")!)
                    #endif
                }, .default(Text("Яндекс.Карты")) {
                    #if !os(watchOS)
                    UIApplication.shared.open(URL(string: "yandexmaps://maps.yandex.ru/?pt=\(localInspections.longitude),\(localInspections.latitude)")!)
                    #endif
                }, .cancel()
            ])
        }
        .alert(isPresented: $sessionStore.showAlert) {
            switch sessionStore.alertType {
            case .success:
                return Alert(title: Text("Успешно"), message: Text("Осмотр успешно загружен на сервер."), dismissButton: .default(Text("Закрыть"), action: delete))
            case .error:
                return Alert(title: Text("Ошибка"), message: Text("Попробуйте загрузить осмотр позже."), dismissButton: .default(Text("Закрыть")))
            case .emptyLocation:
                return Alert(title: Text("Успешно"), message: Text("Осмотр успешно загружен на сервер."), dismissButton: .default(Text("Закрыть"), action: delete))
            case .emptyPhoto:
                return Alert(title: Text("Успешно"), message: Text("Осмотр успешно загружен на сервер."), dismissButton: .default(Text("Закрыть"), action: delete))
            case .emptyTextField:
                return Alert(title: Text("Успешно"), message: Text("Осмотр успешно загружен на сервер."), dismissButton: .default(Text("Закрыть"), action: delete))
            }
        }
        .onAppear {
            if yandexGeo == nil {
                sessionStore.loadAddress(latitude: localInspections.latitude, longitude: localInspections.longitude) { yandexGeoResponse, yandexGeoStateResponse in
                    yandexGeo = yandexGeoResponse
                    yandexGeoState = yandexGeoStateResponse
                }
            }
        }
    }
}
