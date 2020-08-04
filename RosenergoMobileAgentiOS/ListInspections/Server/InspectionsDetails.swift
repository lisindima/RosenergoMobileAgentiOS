//
//  InspectionsDetails.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 23.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import URLImage
import CoreLocation
#if !os(watchOS)
import AVKit
import MapKit
#endif

struct InspectionsDetails: View {
    
    @EnvironmentObject private var sessionStore: SessionStore
    
    @State private var address: String?
    
    #if !os(watchOS)
    @State private var presentMapActionSheet: Bool = false
    @State private var showAlert: Bool = false
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    #endif
    
    var inspection: Inspections
    
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
    
    var footerMap: Text {
        #if os(watchOS)
        return Text("")
        #else
        return Text("Для того, чтобы открыть это местоположение в приложение карт, нажмите на адрес.")
        #endif
    }
    
    var body: some View {
        #if os(watchOS)
        formInspections
        #else
        formInspections
            .actionSheet(isPresented: $presentMapActionSheet) {
                ActionSheet(title: Text("Выберите приложение"), message: Text("В каком приложение вы хотите открыть это местоположение?"), buttons: [.default(Text("Apple Maps")) {
                    UIApplication.shared.open(URL(string: "https://maps.apple.com/?daddr=\(inspection.latitude),\(inspection.longitude)")!)
                }, .default(Text("Яндекс.Карты")) {
                    UIApplication.shared.open(URL(string: "yandexmaps://maps.yandex.ru/?pt=\(inspection.longitude),\(inspection.latitude)")!)
                }, .cancel()
                ])
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(action: {
                            UIPasteboard.general.string = "rosenergo://share?inspection=\(inspection.id)"
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
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Ссылка скопирована"), message: Text("Ссылка на осмотр успешно скопирована в буфер обмена."), dismissButton: .default(Text("Закрыть")))
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
                                NavigationLink(destination: ImageDetail(photos: inspection.photos)) {
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
            #if !os(watchOS)
            if inspection.video != nil {
                Section(header: Text("Видео").fontWeight(.bold)) {
                    VideoPlayer(player: AVPlayer(url:  URL(string: inspection.video!)!))
                        .frame(height: 200)
                        .cornerRadius(10)
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
                        title: inspection.insuranceContractNumber2!
                    )
                    SectionItem(
                        imageName: "car",
                        imageColor: .rosenergo,
                        subTitle: "Модель автомобиля",
                        title: inspection.carModel2!
                    )
                    SectionItem(
                        imageName: "rectangle",
                        imageColor: .rosenergo,
                        subTitle: "Регистрационный номер",
                        title: inspection.carRegNumber2!
                    )
                    SectionItem(
                        imageName: "v.circle",
                        imageColor: .rosenergo,
                        subTitle: "VIN",
                        title: inspection.carVin2!
                    )
                    SectionItem(
                        imageName: "textformat.123",
                        imageColor: .rosenergo,
                        subTitle: "Номер кузова",
                        title: inspection.carBodyNumber2!
                    )
                }
            }
            Section(header: Text("Место проведения осмотра").fontWeight(.bold), footer: footerMap) {
                #if os(watchOS)
                SectionItem(
                    imageName: "map",
                    imageColor: .rosenergo,
                    title: address
                )
                #else
                Button(action: {
                    presentMapActionSheet = true
                }) {
                    SectionItem(
                        imageName: "map",
                        imageColor: .rosenergo,
                        title: address
                    )
                }
                Map(coordinateRegion: $region)
                    .frame(height: 200)
                    .cornerRadius(10)
                    .padding(.vertical, 8)
                #endif
            }
        }
        .navigationTitle("Осмотр: \(inspection.id)")
        .onAppear {
            let location = CLLocation(latitude: inspection.latitude, longitude: inspection.longitude)
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
