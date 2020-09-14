//
//  LinkDetails.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 31.07.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

#if !os(watchOS)
import AVKit
#endif
import SwiftUI
import URLImage

struct LinkDetails: View {
    @EnvironmentObject private var sessionStore: SessionStore
    
    @Environment(\.presentationMode) private var presentationMode
    
    @Binding var inspectionID: String
    
    @State private var inspection: Inspections?
    @State private var fileType: FileType? = nil
    
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
    
    func getInspections() {
        sessionStore.load("inspection/" + "\(inspectionID)") { [self] (response: Result<Inspections, Error>) in
            switch response {
            case let .success(value):
                inspection = value
            case let .failure(error):
                presentationMode.wrappedValue.dismiss()
                log(error)
            }
        }
    }
    
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
        fileType = .photo
        sessionStore.download(inspection!.photos, fileType: .photo) { [self] result in
            switch result {
            case let .success(response):
                photoURL.append(response)
                if photoURL.count == inspection!.photos.count {
                    showShareSheet(activityItems: photoURL)
                    fileType = nil
                }
            case let .failure(error):
                fileType = nil
                log(error)
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
                log(error)
            }
        }
    }
    #endif
    
    var body: some View {
        NavigationView {
            if inspection == nil {
                ProgressView("Загрузка")
                    .onAppear(perform: getInspections)
            } else {
                Form {
                    if !inspection!.photos.isEmpty {
                        Section(header: Text("Фотографии").fontWeight(.bold)) {
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack {
                                    ForEach(inspection!.photos, id: \.id) { photo in
                                        NavigationLink(destination: ImageDetail(id: photo.id, photos: inspection!.photos)) {
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
                    if let url = inspection?.video {
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
                            title: inspection?.createdAt.convertDate()
                        )
                    }
                    Section(header: Text(inspection?.carModel2 != nil ? "Первый автомобиль" : "Информация").fontWeight(.bold)) {
                        SectionItem(
                            imageName: "doc.plaintext",
                            subTitle: "Страховой полис",
                            title: inspection?.insuranceContractNumber
                        )
                        SectionItem(
                            imageName: "car",
                            subTitle: "Модель автомобиля",
                            title: inspection?.carModel
                        )
                        SectionItem(
                            imageName: "rectangle",
                            subTitle: "Регистрационный номер",
                            title: inspection?.carRegNumber
                        )
                        SectionItem(
                            imageName: "v.circle",
                            subTitle: "VIN",
                            title: inspection?.carVin
                        )
                        SectionItem(
                            imageName: "textformat.123",
                            subTitle: "Номер кузова",
                            title: inspection?.carBodyNumber
                        )
                    }
                    if inspection?.carModel2 != nil {
                        Section(header: Text("Второй автомобиль").fontWeight(.bold)) {
                            SectionItem(
                                imageName: "doc.plaintext",
                                subTitle: "Страховой полис",
                                title: inspection?.insuranceContractNumber2
                            )
                            SectionItem(
                                imageName: "car",
                                subTitle: "Модель автомобиля",
                                title: inspection?.carModel2
                            )
                            SectionItem(
                                imageName: "rectangle",
                                subTitle: "Регистрационный номер",
                                title: inspection?.carRegNumber2
                            )
                            SectionItem(
                                imageName: "v.circle",
                                subTitle: "VIN",
                                title: inspection?.carVin2
                            )
                            SectionItem(
                                imageName: "textformat.123",
                                subTitle: "Номер кузова",
                                title: inspection?.carBodyNumber2
                            )
                        }
                    }
                    Section(header: Text("Место проведения осмотра").fontWeight(.bold), footer: Text("Для того, чтобы открыть это местоположение в приложение карт, нажмите на адрес.")) {
                        MapView(latitude: inspection!.latitude, longitude: inspection!.longitude)
                    }
                }
                .navigationTitle("Осмотр: \(inspection!.id)")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            Text("Закрыть")
                        }
                    }
                    #if !os(watchOS)
                    ToolbarItem(placement: .principal) {
                        if let fileType = fileType {
                            DownloadIndicator(fileType: fileType)
                        }
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Menu {
                            if !inspection!.photos.isEmpty {
                                Button(action: downloadPhoto) {
                                    Label("Загрузить фото", systemImage: "photo.on.rectangle.angled")
                                }
                            }
                            if let url = inspection?.video {
                                Button(action: { downloadVideo(url) }) {
                                    Label("Загрузить видео", systemImage: "video")
                                }
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle.fill")
                                .imageScale(.large)
                        }
                    }
                    #endif
                }
            }
        }
    }
}
