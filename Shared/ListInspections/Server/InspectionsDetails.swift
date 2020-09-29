//
//  InspectionsDetails.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 23.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
#if os(iOS)
import AVKit
#endif

struct InspectionsDetails: View {
    @EnvironmentObject private var sessionStore: SessionStore
    
    #if os(iOS)
    @State private var alertItem: AlertItem? = nil
    @State private var fileType: FileType? = nil
    #endif
    
    var inspection: Inspections
    
    #if os(iOS)
    private func showShareSheet(activityItems: [Any]) {
        DispatchQueue.main.async {
            let shareSheet = UIHostingController(
                rootView: ShareSheet(activityItems: activityItems)
                    .ignoresSafeArea(edges: .bottom)
            )
            UIApplication.shared.windows.first?.rootViewController?.present(
                shareSheet, animated: true, completion: nil
            )
        }
    }
    
    private func downloadPhoto() {
        var photoURL: [URL] = []
        fileType = .photo
        sessionStore.download(inspection.photos, fileType: .photo) { [self] result in
            switch result {
            case let .success(response):
                photoURL.append(response)
                if photoURL.count == inspection.photos.count {
                    showShareSheet(activityItems: photoURL)
                    fileType = nil
                }
            case let .failure(error):
                fileType = nil
                log(error.localizedDescription)
            }
        }
    }
    
    private func downloadVideo(_ url: URL) {
        fileType = .video
        sessionStore.download([url], fileType: .video) { [self] result in
            switch result {
            case let .success(response):
                fileType = nil
                showShareSheet(activityItems: [response])
            case let .failure(error):
                fileType = nil
                log(error.localizedDescription)
            }
        }
    }
    #endif
    
    var body: some View {
        #if os(watchOS)
        formInspections
        #else
        formInspections
            .toolbar {
                ToolbarItem(placement: .principal) {
                    if let fileType = fileType {
                        DownloadIndicator(fileType: fileType)
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(action: {
                            UIPasteboard.general.url = URL(string: "rosenergo://share?inspection=\(inspection.id)")
                            alertItem = AlertItem(title: "Ссылка скопирована", message: "Ссылка на осмотр успешно скопирована в буфер обмена.")
                        }) {
                            Label("Скопировать", systemImage: "link")
                        }
                        if !inspection.photos.isEmpty {
                            Button(action: downloadPhoto) {
                                Label("Загрузить фото", systemImage: "photo.on.rectangle.angled")
                            }
                        }
                        if let url = inspection.video {
                            Button(action: { downloadVideo(url) }) {
                                Label("Загрузить видео", systemImage: "video")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                            .imageScale(.large)
                    }
                }
            }
            .customAlert(item: $alertItem)
            .userActivity("com.rosenergomobileagent.inspectionsdetails", element: inspection.id) { url, activity in
                activity.addUserInfoEntries(from: ["url": URL(string: "rosenergo://share?inspection=\(url)")!])
            }
        #endif
    }
    
    var formInspections: some View {
        Form {
            if !inspection.photos.isEmpty {
                Section(header: Text("Фотографии").fontWeight(.bold)) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack {
                            ForEach(inspection.photos, id: \.id) { photo in
                                NavigationLink(destination: ImageDetail(id: photo.id, photos: inspection.photos)) {
                                    ServerImage(photo.path, delay: 0.25)
                                }.buttonStyle(PlainButtonStyle())
                            }
                        }.padding(.vertical, 8)
                    }
                }
            }
            #if os(iOS)
            if let url = inspection.video {
                Section(header: Text("Видео").fontWeight(.bold)) {
                    VideoPlayer(player: AVPlayer(url: url))
                        .frame(height: 200)
                        .cornerRadius(8)
                        .padding(.vertical, 8)
                }
            }
            #endif
            Section(header: Text("Дата загрузки осмотра").fontWeight(.bold)) {
                SectionItem(
                    imageName: "timer",
                    title: inspection.createdAt.convertDate()
                )
            }
            Section(header: Text(inspection.carModel2 != nil ? "Первый автомобиль" : "Информация").fontWeight(.bold)) {
                SectionItem(
                    imageName: "doc.plaintext",
                    subTitle: "Страховой полис",
                    title: inspection.insuranceContractNumber
                )
                SectionItem(
                    imageName: "car",
                    subTitle: "Модель автомобиля",
                    title: inspection.carModel
                )
                SectionItem(
                    imageName: "rectangle",
                    subTitle: "Регистрационный номер",
                    title: inspection.carRegNumber
                )
                SectionItem(
                    imageName: "v.circle",
                    subTitle: "VIN",
                    title: inspection.carVin
                )
                SectionItem(
                    imageName: "textformat.123",
                    subTitle: "Номер кузова",
                    title: inspection.carBodyNumber
                )
            }
            if inspection.carModel2 != nil {
                Section(header: Text("Второй автомобиль").fontWeight(.bold)) {
                    SectionItem(
                        imageName: "doc.plaintext",
                        subTitle: "Страховой полис",
                        title: inspection.insuranceContractNumber2
                    )
                    SectionItem(
                        imageName: "car",
                        subTitle: "Модель автомобиля",
                        title: inspection.carModel2
                    )
                    SectionItem(
                        imageName: "rectangle",
                        subTitle: "Регистрационный номер",
                        title: inspection.carRegNumber2
                    )
                    SectionItem(
                        imageName: "v.circle",
                        subTitle: "VIN",
                        title: inspection.carVin2
                    )
                    SectionItem(
                        imageName: "textformat.123",
                        subTitle: "Номер кузова",
                        title: inspection.carBodyNumber2
                    )
                }
            }
            Section(header: Text("Место проведения осмотра").fontWeight(.bold), footer: Text("Для того, чтобы открыть это местоположение в приложение карт, нажмите на адрес.")) {
                MapView(latitude: inspection.latitude, longitude: inspection.longitude)
            }
        }
        .navigationTitle("Осмотр: \(inspection.id)")
    }
}
