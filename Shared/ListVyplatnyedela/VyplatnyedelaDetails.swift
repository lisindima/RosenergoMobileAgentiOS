//
//  VyplatnyedelaDetails.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 30.07.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct VyplatnyedelaDetails: View {
    @EnvironmentObject private var sessionStore: SessionStore
    
    #if os(iOS)
    @State private var alertItem: AlertItem? = nil
    @State private var shareSheetItem: ShareSheetItem? = nil
    @State private var fileType: FileType? = nil
    #endif
    
    var vyplatnyedela: Vyplatnyedela
    
    #if os(iOS)
    private func downloadPhoto() {
        var photoURL: [URL] = []
        fileType = .photo
        sessionStore.download(vyplatnyedela.photos, fileType: .photo) { [self] result in
            switch result {
            case let .success(response):
                photoURL.append(response)
                if photoURL.count == vyplatnyedela.photos.count {
                    shareSheetItem = ShareSheetItem(activityItems: photoURL)
                    fileType = nil
                }
            case let .failure(error):
                fileType = nil
                log(error.localizedDescription)
            }
        }
    }
    #endif
    
    var body: some View {
        #if os(watchOS)
        form
        #else
        form
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    if let fileType = fileType {
                        DownloadIndicator(fileType: fileType)
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(action: {
                            UIPasteboard.general.url = URL(string: "rosenergo://share?delo=\(vyplatnyedela.id)")
                            alertItem = AlertItem(title: "Ссылка скопирована", message: "Cсылка на выплатное дело успешно скопирована в буфер обмена.")
                        }) {
                            Label("Скопировать", systemImage: "link")
                        }
                        if !vyplatnyedela.photos.isEmpty {
                            Button(action: downloadPhoto) {
                                Label("Загрузить фото", systemImage: "photo.on.rectangle.angled")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                            .imageScale(.large)
                    }
                }
            }
            .customAlert(item: $alertItem)
            .shareSheet(item: $shareSheetItem)
            .userActivity("com.rosenergomobileagent.inspectionsdetails", element: vyplatnyedela.id) { url, activity in
                activity.addUserInfoEntries(from: ["url": URL(string: "rosenergo://share?delo=\(url)")!])
            }
        #endif
    }
    
    var form: some View {
        Form {
            if !vyplatnyedela.photos.isEmpty {
                Section(header: Text("Фотографии").fontWeight(.bold)) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack {
                            ForEach(vyplatnyedela.photos, id: \.id) { photo in
                                NavigationLink(destination: ImageDetail(id: photo.id, photos: vyplatnyedela.photos)) {
                                    ServerImage(photo.path, delay: 0.25)
                                }.buttonStyle(PlainButtonStyle())
                            }
                        }.padding(.vertical, 8)
                    }
                }
            }
            Section(header: Text("Дата загрузки выплатного дела").fontWeight(.bold)) {
                SectionItem(
                    imageName: "timer",
                    title: vyplatnyedela.createdAt.convertDate()
                )
            }
            Section(header: Text("Информация").fontWeight(.bold)) {
                SectionItem(
                    imageName: "doc.plaintext",
                    subTitle: "Номер заявления",
                    title: vyplatnyedela.numberZayavlenia
                )
                SectionItem(
                    imageName: "car",
                    subTitle: "Номер полиса",
                    title: vyplatnyedela.insuranceContractNumber
                )
            }
        }
        .navigationTitle("Дело: \(vyplatnyedela.id)")
    }
}
