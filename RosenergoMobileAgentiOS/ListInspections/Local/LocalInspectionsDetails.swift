//
//  LocalInspectionsDetails.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 23.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import CoreLocation
import MapKit
#if !os(watchOS)
import AVKit
#endif

struct LocalInspectionsDetails: View {
    
    #if !os(watchOS)
    @EnvironmentObject private var notificationStore: NotificationStore
    #endif
    
    @EnvironmentObject private var sessionStore: SessionStore
    
    @Environment(\.managedObjectContext) private var moc
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var address: String?
    @State private var pins: [Pin] = []
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
        
        var photos: [PhotoParameters] = []
        var video: String?
        
        for photo in localInspections.localPhotos! {
            let encodedPhoto = photo.photosData!.base64EncodedString()
            photos.append(PhotoParameters(latitude: localInspections.latitude, longitude: localInspections.longitude, file: encodedPhoto, maked_photo_at: localInspections.dateInspections!))
        }
        
        do {
            let videoData = try Data(contentsOf: URL(string: localInspections.videoURL!)!)
            video = videoData.base64EncodedString()
        } catch {
           print(error)
        }
        
        sessionStore.uploadInspections(
            parameters: InspectionParameters(
                car_model: localInspections.carModel!,
                car_reg_number: localInspections.carRegNumber!,
                car_body_number: localInspections.carBodyNumber!,
                car_vin: localInspections.carVin!,
                insurance_contract_number: localInspections.insuranceContractNumber!,
                car_model2: localInspections.carModel2,
                car_reg_number2: localInspections.carRegNumber2,
                car_body_number2: localInspections.carBodyNumber2,
                car_vin2: localInspections.carVin2,
                insurance_contract_number2: localInspections.insuranceContractNumber2,
                latitude: localInspections.latitude,
                longitude: localInspections.longitude,
                video: video,
                photos: photos
            )
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
        formLocalInspections
            .ignoresSafeArea(edges: .bottom)
        #else
        formLocalInspections
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(action: {}) {
                            Label("Изменить", systemImage: "pencil")
                        }
                        Button(action: delete) {
                            Label("Удалить", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                            .imageScale(.large)
                    }
                }
            }
        #endif
    }
    
    var formLocalInspections: some View {
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
                                            .cornerRadius(8)
                                    }.buttonStyle(PlainButtonStyle())
                                }
                            }.padding(.vertical, 8)
                        }
                    }
                }
                #if !os(watchOS)
                if localInspections.videoURL != nil {
                    Section(header: Text("Видео").fontWeight(.bold)) {
                        VideoPlayer(player: AVPlayer(url: URL(string: localInspections.videoURL!)!))
                            .frame(height: 200)
                            .cornerRadius(8)
                            .padding(.vertical, 8)
                    }
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
                            title: localInspections.insuranceContractNumber
                        )
                        SectionItem(
                            imageName: "car",
                            imageColor: .rosenergo,
                            subTitle: "Модель автомобиля",
                            title: localInspections.carModel
                        )
                        SectionItem(
                            imageName: "rectangle",
                            imageColor: .rosenergo,
                            subTitle: "Регистрационный номер",
                            title: localInspections.carRegNumber
                        )
                        SectionItem(
                            imageName: "v.circle",
                            imageColor: .rosenergo,
                            subTitle: "VIN",
                            title: localInspections.carVin
                        )
                        SectionItem(
                            imageName: "textformat.123",
                            imageColor: .rosenergo,
                            subTitle: "Номер кузова",
                            title: localInspections.carBodyNumber
                        )
                    }
                }
                if localInspections.carModel2 != nil {
                    Section(header: Text("Второй автомобиль").fontWeight(.bold)) {
                        SectionItem(
                            imageName: "doc.plaintext",
                            imageColor: .rosenergo,
                            subTitle: "Страховой полис",
                            title: localInspections.insuranceContractNumber2
                        )
                        SectionItem(
                            imageName: "car",
                            imageColor: .rosenergo,
                            subTitle: "Модель автомобиля",
                            title: localInspections.carModel2
                        )
                        SectionItem(
                            imageName: "rectangle",
                            imageColor: .rosenergo,
                            subTitle: "Регистрационный номер",
                            title: localInspections.carRegNumber2
                        )
                        SectionItem(
                            imageName: "v.circle",
                            imageColor: .rosenergo,
                            subTitle: "VIN",
                            title: localInspections.carVin2
                        )
                        SectionItem(
                            imageName: "textformat.123",
                            imageColor: .rosenergo,
                            subTitle: "Номер кузова",
                            title: localInspections.carBodyNumber2
                        )
                    }
                }
                Section(header: Text("Место проведения осмотра").fontWeight(.bold), footer: Text("Для того, чтобы открыть это местоположение в приложение карт, нажмите на адрес.")) {
                    SectionLink(
                        imageName: "map",
                        imageColor: .rosenergo,
                        title: address,
                        titleColor: .primary,
                        destination: URL(string: "yandexmaps://maps.yandex.ru/?pt=\(localInspections.longitude),\(localInspections.latitude)")!
                    )
                    Map(coordinateRegion: $region, annotationItems: pins) { pin in
                        MapMarker(coordinate: pin.coordinate, tint: .rosenergo)
                    }
                    .frame(height: 200)
                    .cornerRadius(8)
                    .padding(.vertical)
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
                    .padding(.bottom, 8)
                #endif
            }
        }
        .navigationTitle("Не отправлено")
        .alert(isPresented: $sessionStore.showAlert) {
            switch sessionStore.alertType {
            case .success:
                return Alert(title: Text("Успешно"), message: Text("Осмотр успешно загружен на сервер."), dismissButton: .default(Text("Закрыть"), action: delete))
            case .error:
                return Alert(title: Text("Ошибка"), message: Text("Попробуйте загрузить осмотр позже.\n\(sessionStore.alertError ?? "")"), dismissButton: .default(Text("Закрыть")))
            case .emptyLocation:
                return Alert(title: Text("Успешно"), message: Text("Осмотр успешно загружен на сервер."), dismissButton: .default(Text("Закрыть"), action: delete))
            case .emptyPhoto:
                return Alert(title: Text("Успешно"), message: Text("Осмотр успешно загружен на сервер."), dismissButton: .default(Text("Закрыть"), action: delete))
            case .emptyTextField:
                return Alert(title: Text("Успешно"), message: Text("Осмотр успешно загружен на сервер."), dismissButton: .default(Text("Закрыть"), action: delete))
            }
        }
        .onAppear {
            region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: localInspections.latitude, longitude: localInspections.longitude), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            pins.append(Pin(coordinate: .init(latitude: localInspections.latitude, longitude: localInspections.longitude)))
            let location = CLLocation(latitude: localInspections.latitude, longitude: localInspections.longitude)
            location.geocode { placemark, error in
                if let error = error {
                    print(error)
                    return
                } else if let placemark = placemark?.first {
                    address = "\(placemark.country ?? ""), \(placemark.administrativeArea ?? ""), \(placemark.locality ?? ""), \(placemark.name ?? "")"
                }
            }
        }
    }
}
