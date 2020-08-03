//
//  LocalInspectionsDetails.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 23.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import CoreLocation
#if !os(watchOS)
import AVKit
import MapKit
#endif

struct LocalInspectionsDetails: View {
    
    @EnvironmentObject private var sessionStore: SessionStore
    #if !os(watchOS)
    @EnvironmentObject private var notificationStore: NotificationStore
    #endif
    
    @Environment(\.managedObjectContext) private var moc
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var presentMapActionSheet: Bool = false
    @State private var address: String = ""
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    
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
        
        var photoParameters: [PhotoParameters] = []
        
        for photo in localInspections.localPhotos! {
            let encodedPhoto = photo.photosData!.base64EncodedString()
            photoParameters.append(PhotoParameters(latitude: localInspections.latitude, longitude: localInspections.longitude, file: encodedPhoto, maked_photo_at: localInspections.dateInspections!))
        }
        
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
            photoParameters: photoParameters,
            video: nil
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
            .ignoresSafeArea(edges: .bottom)
        #else
        details
        #endif
    }
    
    var details: some View {
        VStack {
            Form {
                if !localInspections.arrayPhoto.isEmpty {
                    Section(header: Text("Фотографии").fontWeight(.bold)) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack {
                                ForEach(localInspections.arrayPhoto, id: \.id) { photo in
                                    NavigationLink(destination: LocalImageDetail(photos: localInspections.arrayPhoto)) {
                                        Image(uiImage: UIImage(data: photo.photosData!)!.resizedImage(width: CGFloat(size), height: CGFloat(size)))
                                            .resizable()
                                            .frame(width: CGFloat(size), height: CGFloat(size))
                                            .cornerRadius(10)
                                    }.buttonStyle(PlainButtonStyle())
                                }
                            }.padding(.vertical, 8)
                        }
                    }
                }
                #if !os(watchOS)
                Section(header: Text("Видео").fontWeight(.bold)) {
                    VideoPlayer(player: AVPlayer(url:  URL(string: "https://bit.ly/swswift")!))
                        .frame(height: 200)
                        .cornerRadius(10)
                        .padding(.vertical, 8)
                }
                #endif
                if localInspections.dateInspections != nil {
                    Section(header: Text("Дата создания осмотра").fontWeight(.bold)) {
                        SectionItem(
                            imageName: "timer",
                            imageColor: .rosenergo,
                            title: localInspections.dateInspections!.dataInspection(local: true)
                        )
                    }
                }
                if localInspections.carModel != nil {
                    Section(header: Text(localInspections.carModel2 != nil ? "Первый автомобиль" : "Информация").fontWeight(.bold)) {
                        SectionItem(
                            imageName: "doc.plaintext",
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
                            imageName: "doc.plaintext",
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
                Section(header: Text("Место проведения осмотра").fontWeight(.bold), footer: Text("Для того, чтобы открыть это местоположение в приложение карт, нажмите на адрес.")) {
                    Button(action: {
                        presentMapActionSheet = true
                    }) {
                        SectionItem(
                            imageName: "map",
                            imageColor: .rosenergo,
                            title: address
                        )
                    }
                    #if !os(watchOS)
                    Map(coordinateRegion: $region)
                        .frame(height: 200)
                        .cornerRadius(10)
                        .padding(.vertical, 8)
                    #endif
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
                UploadIndicator(progress: $sessionStore.uploadProgress)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                #else
                ProgressView()
                #endif
            }
        }
        .navigationTitle("Не отправлено")
        .toolbar {
            #if os(watchOS)
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    print("Поделиться")
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .imageScale(.large)
                }
            }
            #else
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button(action: {}) {
                        Label("Изменить", systemImage: "pencil")
                    }
                    Button(action: {}) {
                        Label("Поделиться", systemImage: "square.and.arrow.up")
                    }
                    Button(action: {}) {
                        Label("Удалить", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .imageScale(.large)
                }
            }
            #endif
        }
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
            let location = CLLocation(latitude: localInspections.latitude, longitude: localInspections.longitude)
            location.geocode { placemark, error in
                if let error = error as? CLError {
                    print("CLError:", error)
                    return
                } else if let placemark = placemark?.first {
                    address = "\(placemark.country ?? ""), \(placemark.administrativeArea ?? ""), \(placemark.locality ?? ""), \(placemark.name ?? "")"
                }
            }
        }
    }
}
