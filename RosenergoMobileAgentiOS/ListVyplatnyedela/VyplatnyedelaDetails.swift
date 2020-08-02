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
    
    @State private var showAlert: Bool = false
    
    var vyplatnyedela: Vyplatnyedela
    
    var scale: CGFloat {
        #if os(watchOS)
        return WKInterfaceDevice.current().screenScale
        #else
        return UIScreen.main.scale
        #endif
    }
    
    var size: Double {
        #if os(watchOS)
        return 75.0
        #else
        return 100.0
        #endif
    }
    
    var body: some View {
        Form {
            if !vyplatnyedela.photos.isEmpty {
                Section(header: Text("Фотографии").fontWeight(.bold)) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack {
                            ForEach(vyplatnyedela.photos, id: \.id) { photo in
                                NavigationLink(destination: ImageDetail(photos: vyplatnyedela.photos)) {
                                    URLImage(URL(string: photo.path)!, delay: 0.25, processors: [Resize(size: CGSize(width: size, height: size), scale: scale)], placeholder: { _ in
                                        ProgressView()
                                    }, content: {
                                        $0.image
                                            .resizable()
                                    })
                                    .cornerRadius(10)
                                    .frame(width: CGFloat(size), height: CGFloat(size))
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
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Ссылка скопирована"), message: Text("Ссылка на осмотр успешно скопирована в буфер обмена."), dismissButton: .default(Text("Закрыть")))
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                #if os(watchOS)
                Button(action: {
                    print("Скопировать")
                }) {
                    Label("Скопировать", systemImage: "link")
                }
                #else
                Menu {
                    Button(action: {
                        UIPasteboard.general.string = "rosenergo://share?inspection=\(vyplatnyedela.id)"
                        showAlert = true
                    }) {
                        Label("Скопировать", systemImage: "link")
                    }
                    Button(action: {}) {
                        Label("Загрузить", systemImage: "square.and.arrow.down")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .imageScale(.large)
                }
                #endif
            }
        }
    }
}