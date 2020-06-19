//
//  InspectionsDetails.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 23.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import URLImage

struct InspectionsDetails: View {
    
    @EnvironmentObject var sessionStore: SessionStore
    
    @State private var presentMapActionSheet: Bool = false
    
    var inspection: Inspections
    
    var body: some View {
        Form {
            if !inspection.photos.isEmpty {
                Section(header: Text("Фотографии".uppercased())) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(inspection.photos, id: \.id) { photo in
                                NavigationLink(destination: ImageDetail(photo: photo.path)) {
                                    URLImage(URL(string: photo.path)!, processors: [Resize(size: CGSize(width: 100.0, height: 100.0), scale: UIScreen.main.scale)], placeholder: { _ in
                                        ActivityIndicator(styleSpinner: .medium)
                                    }) { proxy in
                                        proxy.image
                                            .renderingMode(.original)
                                            .resizable()
                                    }
                                    .cornerRadius(10)
                                    .frame(width: 100, height: 100)
                                }
                            }
                        }.padding(.vertical, 8)
                    }
                }
            }
            Section(header: Text("Дата осмотра".uppercased())) {
                HStack {
                    Image(systemName: "timer")
                        .frame(width: 24)
                        .foregroundColor(.rosenergo)
                    VStack(alignment: .leading) {
                        Text("Дата загрузки осмотра")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Text(inspection.createdat.dataInspection())
                    }
                }
            }
            Section(header: Text(inspection.carModel2 != nil ? "Первый автомобиль".uppercased() : "Информация".uppercased())) {
                HStack {
                    Image(systemName: "car")
                        .frame(width: 24)
                        .foregroundColor(.rosenergo)
                    VStack(alignment: .leading) {
                        Text("Модель автомобиля")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Text(inspection.carModel)
                    }
                }
                HStack {
                    Image(systemName: "rectangle")
                        .frame(width: 24)
                        .foregroundColor(.rosenergo)
                    VStack(alignment: .leading) {
                        Text("Регистрационный номер")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Text(inspection.carRegNumber)
                    }
                }
                HStack {
                    Image(systemName: "v.circle")
                        .frame(width: 24)
                        .foregroundColor(.rosenergo)
                    VStack(alignment: .leading) {
                        Text("VIN")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Text(inspection.carVin)
                    }
                }
                HStack {
                    Image(systemName: "textformat.123")
                        .frame(width: 24)
                        .foregroundColor(.rosenergo)
                    VStack(alignment: .leading) {
                        Text("Номер кузова")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Text(inspection.carBodyNumber)
                    }
                }
                HStack {
                    Image(systemName: "text.justify")
                        .frame(width: 24)
                        .foregroundColor(.rosenergo)
                    VStack(alignment: .leading) {
                        Text("Страховой полис")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Text(inspection.insuranceContractNumber)
                    }
                }
            }
            if inspection.carModel2 != nil {
                Section(header: Text("Второй автомобиль".uppercased())) {
                    HStack {
                        Image(systemName: "car")
                            .frame(width: 24)
                            .foregroundColor(.rosenergo)
                        VStack(alignment: .leading) {
                            Text("Модель автомобиля")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Text(inspection.carModel2!)
                        }
                    }
                    HStack {
                        Image(systemName: "rectangle")
                            .frame(width: 24)
                            .foregroundColor(.rosenergo)
                        VStack(alignment: .leading) {
                            Text("Регистрационный номер")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Text(inspection.carRegNumber2!)
                        }
                    }
                    HStack {
                        Image(systemName: "v.circle")
                            .frame(width: 24)
                            .foregroundColor(.rosenergo)
                        VStack(alignment: .leading) {
                            Text("VIN")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Text(inspection.carVin2!)
                        }
                    }
                    HStack {
                        Image(systemName: "textformat.123")
                            .frame(width: 24)
                            .foregroundColor(.rosenergo)
                        VStack(alignment: .leading) {
                            Text("Номер кузова")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Text(inspection.carBodyNumber2!)
                        }
                    }
                    HStack {
                        Image(systemName: "text.justify")
                            .frame(width: 24)
                            .foregroundColor(.rosenergo)
                        VStack(alignment: .leading) {
                            Text("Страховой полис")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Text(inspection.insuranceContractNumber2!)
                        }
                    }
                }
            }
            Section(header: Text("Место проведения осмотра".uppercased())) {
                Button(action: {
                    self.presentMapActionSheet = true
                }) {
                    if sessionStore.yandexGeoState == .success && sessionStore.yandexGeo?.response.geoObjectCollection.featureMember.first?.geoObject.metaDataProperty.geocoderMetaData.text != nil {
                        HStack {
                            Image(systemName: "map")
                                .frame(width: 24)
                                .foregroundColor(.rosenergo)
                            VStack(alignment: .leading) {
                                Text("Адрес места проведения осмотра")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                                Text(sessionStore.yandexGeo!.response.geoObjectCollection.featureMember.first!.geoObject.metaDataProperty.geocoderMetaData.text!)
                                    .foregroundColor(.primary)
                            }
                        }
                    } else if sessionStore.yandexGeoState == .failure {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .frame(width: 24)
                                .foregroundColor(.yellow)
                            VStack(alignment: .leading) {
                                Text("Ошибка, не удалось определить адрес")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                                Text("Проверьте подключение к интернету!")
                                    .foregroundColor(.primary)
                            }
                        }
                    } else if sessionStore.yandexGeoState == .loading {
                        HStack {
                            ActivityIndicator(styleSpinner: .medium)
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
        .environment(\.horizontalSizeClass, .regular)
        .navigationBarTitle("Осмотр: \(inspection.id)")
        .actionSheet(isPresented: $presentMapActionSheet) {
            ActionSheet(title: Text("Выберите приложение"), message: Text("В каком приложение вы хотите открыть это местоположение?"), buttons: [.default(Text("Apple Maps")) {
                UIApplication.shared.open(URL(string: "https://maps.apple.com/?daddr=\(self.inspection.latitude),\(self.inspection.longitude)")!)
                }, .default(Text("Яндекс.Карты")) {
                    UIApplication.shared.open(URL(string: "yandexmaps://maps.yandex.ru/?pt=\(self.inspection.longitude),\(self.inspection.latitude)")!)
                }, .cancel()
            ])
        }
        .onAppear {
            self.sessionStore.loadYandexGeoResponse(latitude: self.inspection.latitude, longitude: self.inspection.longitude)
        }
        .onDisappear {
            self.sessionStore.yandexGeo = nil
            self.sessionStore.yandexGeoState = .loading
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
