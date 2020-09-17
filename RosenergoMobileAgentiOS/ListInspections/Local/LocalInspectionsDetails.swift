//
//  LocalInspectionsDetails.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 23.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
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
    
    @State private var uploadState: Bool = false
    @State private var alertItem: AlertItem? = nil
    
    var localInspections: LocalInspections
    
    private func delete() {
        #if !os(watchOS)
        notificationStore.cancelNotifications(localInspections.id.uuidString)
        #endif
        presentationMode.wrappedValue.dismiss()
        moc.delete(localInspections)
        do {
            try moc.save()
        } catch {
            log(error.localizedDescription)
        }
    }
    
    private func uploadLocalInspections() {
        uploadState = true
        var photos: [PhotoParameters] = []
        var video: String?
        
        for photo in localInspections.localPhotos {
            let encodedPhoto = photo.photosData.base64EncodedString()
            photos.append(PhotoParameters(latitude: localInspections.latitude, longitude: localInspections.longitude, file: encodedPhoto, makedPhotoAt: "\(localInspections.dateInspections)"))
        }
        
        if let videoURL = localInspections.videoURL {
            do {
                let videoData = try Data(contentsOf: videoURL)
                video = videoData.base64EncodedString()
            } catch {
                log(error.localizedDescription)
            }
        }
        
        sessionStore.upload("testinspection", parameters: InspectionParameters(
            carModel: localInspections.carModel,
            carRegNumber: localInspections.carRegNumber,
            carBodyNumber: localInspections.carBodyNumber,
            carVin: localInspections.carVin,
            insuranceContractNumber: localInspections.insuranceContractNumber,
            carModel2: localInspections.carModel2,
            carRegNumber2: localInspections.carRegNumber2,
            carBodyNumber2: localInspections.carBodyNumber2,
            carVin2: localInspections.carVin2,
            insuranceContractNumber2: localInspections.insuranceContractNumber2,
            latitude: localInspections.latitude,
            longitude: localInspections.longitude,
            video: video,
            photos: photos
        )) { response in
            switch response {
            case .success:
                alertItem = AlertItem(title: "Успешно", message: "Осмотр успешно загружен на сервер.", action: delete)
                playHaptic(.success)
                uploadState = false
            case let .failure(error):
                alertItem = AlertItem(title: "Ошибка", message: "Попробуйте загрузить осмотр позже.\n\(error.localizedDescription)")
                playHaptic(.error)
                uploadState = false
                log(error.localizedDescription)
            }
        }
    }
    
    var size: CGFloat {
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
    
    @ViewBuilder
    var formLocalInspections: some View {
        Form {
            if !localInspections.arrayPhoto.isEmpty {
                Section(header: Text("Фотографии").fontWeight(.bold)) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack {
                            ForEach(localInspections.arrayPhoto, id: \.id) { photo in
                                NavigationLink(destination: LocalImageDetail(id: Int(photo.id), photos: localInspections.arrayPhoto)) {
                                    Image(uiImage: UIImage(data: photo.photosData)!.resizedImage(width: size, height: size))
                                        .resizable()
                                        .frame(width: size, height: size)
                                        .cornerRadius(8)
                                }.buttonStyle(PlainButtonStyle())
                            }
                        }.padding(.vertical, 8)
                    }
                }
            }
            #if !os(watchOS)
            if let url = localInspections.videoURL {
                Section(header: Text("Видео").fontWeight(.bold)) {
                    VideoPlayer(player: AVPlayer(url: url))
                        .frame(height: 200)
                        .cornerRadius(8)
                        .padding(.vertical, 8)
                }
            }
            #endif
            Section(header: Text("Дата создания осмотра").fontWeight(.bold)) {
                SectionItem(
                    imageName: "timer",
                    title: localInspections.dateInspections.convertDate()
                )
            }
            Section(header: Text(localInspections.carModel2 != nil ? "Первый автомобиль" : "Информация").fontWeight(.bold)) {
                SectionItem(
                    imageName: "doc.plaintext",
                    subTitle: "Страховой полис",
                    title: localInspections.insuranceContractNumber
                )
                SectionItem(
                    imageName: "car",
                    subTitle: "Модель автомобиля",
                    title: localInspections.carModel
                )
                SectionItem(
                    imageName: "rectangle",
                    subTitle: "Регистрационный номер",
                    title: localInspections.carRegNumber
                )
                SectionItem(
                    imageName: "v.circle",
                    subTitle: "VIN",
                    title: localInspections.carVin
                )
                SectionItem(
                    imageName: "textformat.123",
                    subTitle: "Номер кузова",
                    title: localInspections.carBodyNumber
                )
            }
            if localInspections.carModel2 != nil {
                Section(header: Text("Второй автомобиль").fontWeight(.bold)) {
                    SectionItem(
                        imageName: "doc.plaintext",
                        subTitle: "Страховой полис",
                        title: localInspections.insuranceContractNumber2
                    )
                    SectionItem(
                        imageName: "car",
                        subTitle: "Модель автомобиля",
                        title: localInspections.carModel2
                    )
                    SectionItem(
                        imageName: "rectangle",
                        subTitle: "Регистрационный номер",
                        title: localInspections.carRegNumber2
                    )
                    SectionItem(
                        imageName: "v.circle",
                        subTitle: "VIN",
                        title: localInspections.carVin2
                    )
                    SectionItem(
                        imageName: "textformat.123",
                        subTitle: "Номер кузова",
                        title: localInspections.carBodyNumber2
                    )
                }
            }
            Section(header: Text("Место проведения осмотра").fontWeight(.bold), footer: Text("Для того, чтобы открыть это местоположение в приложение карт, нажмите на адрес.")) {
                MapView(latitude: localInspections.latitude, longitude: localInspections.longitude)
            }
        }
        CustomButton("Отправить на сервер", titleUpload: "Загрузка осмотра", loading: uploadState, progress: sessionStore.uploadProgress) {
            uploadLocalInspections()
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
        .navigationTitle("Не отправлено")
        .customAlert($alertItem)
    }
}
