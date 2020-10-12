//
//  LocalInspectionsDetails.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 23.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
#if os(iOS)
import WidgetKit
import AVKit
#endif

struct LocalInspectionsDetails: View {
    @EnvironmentObject private var notificationStore: NotificationStore
    @EnvironmentObject private var sessionStore: SessionStore
    
    @Environment(\.managedObjectContext) private var moc
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var uploadState: Bool = false
    @State private var alertItem: AlertItem? = nil
    
    var localInspections: LocalInspections
    
    private func delete() {
        notificationStore.cancelNotifications(localInspections.id.uuidString)
        presentationMode.wrappedValue.dismiss()
        #if os(iOS)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
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
        var video: Data?
        
        for photo in localInspections.localPhotos {
            photos.append(PhotoParameters(latitude: localInspections.latitude, longitude: localInspections.longitude, file: photo.photosData, makedPhotoAt: localInspections.dateInspections))
        }
        
        if let videoURL = localInspections.videoURL {
            do {
                video = try Data(contentsOf: videoURL)
            } catch {
                log(error.localizedDescription)
            }
        }
        
        sessionStore.upload(.uploadInspection, parameters: InspectionParameters(
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
        )) { [self] (result: Result<Inspections, ApiError>) in
            switch result {
            case .success:
                alertItem = AlertItem(title: "Успешно", message: "Осмотр успешно загружен на сервер.", action: delete)
                uploadState = false
            case let .failure(error):
                alertItem = AlertItem(title: "Ошибка", message: "Попробуйте загрузить осмотр позже.\n\(error.localizedDescription)")
                uploadState = false
                log(error.localizedDescription)
            }
        }
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
            if !localInspections.localPhotos.isEmpty {
                Section(header: Text("Фотографии").fontWeight(.bold)) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack {
                            ForEach(Array(localInspections.localPhotos), id: \.id) { photo in
                                NavigationLink(destination: LocalImageDetail(id: Int(photo.id), photos: localInspections.localPhotos)) {
                                    LocalImage(data: photo.photosData)
                                }.buttonStyle(PlainButtonStyle())
                            }
                        }.padding(.vertical, 8)
                    }
                }
            }
            #if os(iOS)
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
                MapView(
                    latitude: localInspections.latitude,
                    longitude: localInspections.longitude
                )
            }
        }
        CustomButton("Отправить на сервер", titleUpload: "Загрузка осмотра", loading: uploadState, progress: sessionStore.uploadProgress, action: uploadLocalInspections)
            .padding(.horizontal)
            .padding(.bottom, 8)
            .navigationTitle("Не отправлено")
            .customAlert(item: $alertItem)
    }
}
