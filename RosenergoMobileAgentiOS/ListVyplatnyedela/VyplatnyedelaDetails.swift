//
//  VyplatnyedelaDetails.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 30.07.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import URLImage

struct VyplatnyedelaDetails: View {
    @EnvironmentObject private var sessionStore: SessionStore

    #if !os(watchOS)
        @State private var showAlert: Bool = false
    #endif

    var vyplatnyedela: Vyplatnyedela

    #if !os(watchOS)
        private func showShareSheet(activityItems: [Any]) {
            DispatchQueue.main.async {
                let shareSheet = UIHostingController(
                    rootView:
                    ShareSheet(activityItems: activityItems)
                        .ignoresSafeArea(edges: .bottom)
                )
                UIApplication.shared.windows.first?.rootViewController?.present(
                    shareSheet, animated: true, completion: nil
                )
            }
        }

        private func downloadPhoto() {
            var photoURL: [URL] = []
            sessionStore.download(vyplatnyedela.photos, fileType: .photo) { [self] result in
                switch result {
                case let .success(response):
                    photoURL.append(response)
                    if photoURL.count == vyplatnyedela.photos.count {
                        showShareSheet(activityItems: photoURL)
                    }
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
            form
        #else
            form
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Menu {
                            Button(action: {
                                UIPasteboard.general.string = "rosenergo://share?delo=\(vyplatnyedela.id)"
                                showAlert = true
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
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Ссылка скопирована"), message: Text("Ссылка на выплатное дело успешно скопирована в буфер обмена."), dismissButton: .cancel())
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
            Section(header: Text("Дата загрузки выплатного дела").fontWeight(.bold)) {
                SectionItem(
                    imageName: "timer",
                    imageColor: .rosenergo,
                    title: vyplatnyedela.createdAt.dataInspection(local: false)
                )
            }
            Section(header: Text("Информация").fontWeight(.bold)) {
                SectionItem(
                    imageName: "doc.plaintext",
                    imageColor: .rosenergo,
                    subTitle: "Номер заявления",
                    title: vyplatnyedela.numberZayavlenia
                )
                SectionItem(
                    imageName: "car",
                    imageColor: .rosenergo,
                    subTitle: "Номер полиса",
                    title: vyplatnyedela.insuranceContractNumber
                )
            }
        }
        .navigationTitle("Дело: \(vyplatnyedela.id)")
    }
}
