//
//  InspectionsDetails.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 23.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import URLImage
#if !os(watchOS)
    import AVKit
#endif

struct InspectionsDetails: View {
    @EnvironmentObject private var sessionStore: SessionStore

    #if !os(watchOS)
        @State private var alertItem: AlertItem? = nil
    #endif

    var inspection: Inspections

    #if !os(watchOS)
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
            sessionStore.download(inspection.photos, fileType: .photo) { [self] result in
                switch result {
                case let .success(response):
                    photoURL.append(response)
                    if photoURL.count == inspection.photos.count {
                        showShareSheet(activityItems: photoURL)
                    }
                case let .failure(error):
                    print(error)
                }
            }
        }

        private func downloadVideo() {
            sessionStore.download([inspection.video!], fileType: .video) { [self] result in
                switch result {
                case let .success(response):
                    showShareSheet(activityItems: [response])
                case let .failure(error):
                    print(error)
                }
            }
        }
    #endif

    var scale: CGFloat {
        #if os(watchOS)
            return WKInterfaceDevice.current().screenScale
        #else
            return UIScreen.main.scale
        #endif
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
            formInspections
        #else
            formInspections
                .toolbar {
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
                            if inspection.video != nil {
                                Button(action: downloadVideo) {
                                    Label("Загрузить видео", systemImage: "video")
                                }
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle.fill")
                                .imageScale(.large)
                        }
                    }
                }
                .alert(item: $alertItem) { error in
                    alert(title: error.title, message: error.message, action: error.action)
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
                                    URLImage(
                                        photo.path,
                                        delay: 0.25,
                                        processors: [Resize(size: CGSize(width: size, height: size), scale: scale)],
                                        placeholder: { _ in
                                            ProgressView()
                                        }
                                    ) {
                                        $0.image
                                            .resizable()
                                    }
                                    .cornerRadius(8)
                                    .frame(width: size, height: size)
                                }.buttonStyle(PlainButtonStyle())
                            }
                        }.padding(.vertical, 8)
                    }
                }
            }
            #if !os(watchOS)
                if inspection.video != nil {
                    Section(header: Text("Видео").fontWeight(.bold)) {
                        VideoPlayer(player: AVPlayer(url: inspection.video!))
                            .frame(height: 200)
                            .cornerRadius(8)
                            .padding(.vertical, 8)
                    }
                }
            #endif
            Section(header: Text("Дата загрузки осмотра").fontWeight(.bold)) {
                SectionItem(
                    imageName: "timer",
                    imageColor: .rosenergo,
                    title: inspection.createdAt.dataInspection(local: false)
                )
            }
            Section(header: Text(inspection.carModel2 != nil ? "Первый автомобиль" : "Информация").fontWeight(.bold)) {
                SectionItem(
                    imageName: "doc.plaintext",
                    imageColor: .rosenergo,
                    subTitle: "Страховой полис",
                    title: inspection.insuranceContractNumber
                )
                SectionItem(
                    imageName: "car",
                    imageColor: .rosenergo,
                    subTitle: "Модель автомобиля",
                    title: inspection.carModel
                )
                SectionItem(
                    imageName: "rectangle",
                    imageColor: .rosenergo,
                    subTitle: "Регистрационный номер",
                    title: inspection.carRegNumber
                )
                SectionItem(
                    imageName: "v.circle",
                    imageColor: .rosenergo,
                    subTitle: "VIN",
                    title: inspection.carVin
                )
                SectionItem(
                    imageName: "textformat.123",
                    imageColor: .rosenergo,
                    subTitle: "Номер кузова",
                    title: inspection.carBodyNumber
                )
            }
            if inspection.carModel2 != nil {
                Section(header: Text("Второй автомобиль").fontWeight(.bold)) {
                    SectionItem(
                        imageName: "doc.plaintext",
                        imageColor: .rosenergo,
                        subTitle: "Страховой полис",
                        title: inspection.insuranceContractNumber2
                    )
                    SectionItem(
                        imageName: "car",
                        imageColor: .rosenergo,
                        subTitle: "Модель автомобиля",
                        title: inspection.carModel2
                    )
                    SectionItem(
                        imageName: "rectangle",
                        imageColor: .rosenergo,
                        subTitle: "Регистрационный номер",
                        title: inspection.carRegNumber2
                    )
                    SectionItem(
                        imageName: "v.circle",
                        imageColor: .rosenergo,
                        subTitle: "VIN",
                        title: inspection.carVin2
                    )
                    SectionItem(
                        imageName: "textformat.123",
                        imageColor: .rosenergo,
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
