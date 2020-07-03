//
//  InspectionsDetails.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 23.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import URLImage
import Alamofire

struct InspectionsDetails: View {
    
    @EnvironmentObject var sessionStore: SessionStore
    
    @State private var presentMapActionSheet: Bool = false
    @State private var yandexGeoState: YandexGeoState = .loading
    @State private var yandexGeo: YandexGeo?
    
    var inspection: Inspections
    
    private func loadYandexGeoResponse() {
        
        let parameters = YandexGeoParameters(
            apikey: sessionStore.apiKeyForYandexGeo,
            format: "json",
            geocode: "\(inspection.longitude), \(inspection.latitude)",
            results: "1",
            kind: "house"
        )
        
        AF.request(sessionStore.yandexGeoURL, method: .get, parameters: parameters)
            .validate()
            .responseDecodable(of: YandexGeo.self) { response in
                switch response.result {
                case .success:
                    guard let yandexGeo = response.value else { return }
                    self.yandexGeo = yandexGeo
                    self.yandexGeoState = .success
                case .failure(let error):
                    print(error)
                    self.yandexGeoState = .failure
                }
        }
    }
    
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
    
    @ViewBuilder var body: some View {
        #if os(watchOS)
        details
        #else
        details
            .environment(\.horizontalSizeClass, .regular)
        #endif
    }
    
    var details: some View {
        Form {
            if !inspection.photos.isEmpty {
                Section(header: Text("Фотографии").fontWeight(.bold)) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
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
            Section(header: Text("Дата осмотра").fontWeight(.bold)) {
                SectionItem(
                    imageName: "timer",
                    imageColor: .rosenergo,
                    subTitle: "Дата загрузки осмотра",
                    title: inspection.createdat.dataInspection()
                )
            }
            Section(header: Text(inspection.carModel2 != nil ? "Первый автомобиль" : "Информация").fontWeight(.bold)) {
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
                SectionItem(
                    imageName: "text.justify",
                    imageColor: .rosenergo,
                    subTitle: "Страховой полис",
                    title: inspection.insuranceContractNumber
                )
            }
            if inspection.carModel2 != nil {
                Section(header: Text("Второй автомобиль").fontWeight(.bold)) {
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
                    SectionItem(
                        imageName: "text.justify",
                        imageColor: .rosenergo,
                        subTitle: "Страховой полис",
                        title: inspection.insuranceContractNumber2!
                    )
                }
            }
            Section(header: Text("Место проведения осмотра").fontWeight(.bold)) {
                Button(action: {
                    self.presentMapActionSheet = true
                }) {
                    if yandexGeoState == .success && yandexGeo?.response.geoObjectCollection.featureMember.first?.geoObject.metaDataProperty.geocoderMetaData.text != nil {
                        SectionItem(
                            imageName: "map",
                            imageColor: .rosenergo,
                            subTitle: "Адрес места проведения осмотра",
                            title: yandexGeo!.response.geoObjectCollection.featureMember.first!.geoObject.metaDataProperty.geocoderMetaData.text!
                        )
                    } else if yandexGeoState == .failure {
                        SectionItem(
                            imageName: "exclamationmark.triangle",
                            imageColor: .yellow,
                            subTitle: "Ошибка, не удалось определить адрес",
                            title: "Проверьте подключение к интернету!"
                        )
                    } else if yandexGeoState == .loading {
                        HStack {
                            ProgressView()
                                .frame(width: 24)
                            VStack(alignment: .leading) {
                                Text("Определяем адрес осмотра")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                                Text("Загрузка")
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
            }
        }
        .navigationBarTitle("Осмотр: \(inspection.id)")
        .actionSheet(isPresented: $presentMapActionSheet) {
            ActionSheet(title: Text("Выберите приложение"), message: Text("В каком приложение вы хотите открыть это местоположение?"), buttons: [.default(Text("Apple Maps")) {
                #if !os(watchOS)
                UIApplication.shared.open(URL(string: "https://maps.apple.com/?daddr=\(self.inspection.latitude),\(self.inspection.longitude)")!)
                #endif
            }, .default(Text("Яндекс.Карты")) {
                #if !os(watchOS)
                UIApplication.shared.open(URL(string: "yandexmaps://maps.yandex.ru/?pt=\(self.inspection.longitude),\(self.inspection.latitude)")!)
                #endif
            }, .cancel()
            ])
        }
        .onAppear {
            if self.yandexGeo == nil {
                self.loadYandexGeoResponse()
            }
        }
    }
}

extension String {
    func dataInspection() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        let date = dateFormatter.date(from: self)
        let newDateFormatter = DateFormatter()
        newDateFormatter.dateFormat = "dd MMM yyyy, HH:mm"
        let stringDate = newDateFormatter.string(from: date!)
        return stringDate
    }
}
