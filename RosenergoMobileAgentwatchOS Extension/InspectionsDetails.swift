//
//  InspectionsDetails.swift
//  RosenergoMobileAgentwatchOS Extension
//
//  Created by Дмитрий Лисин on 16.06.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI
import Espera

struct InspectionsDetails: View {
    
    @ObservedObject var sessionStore: SessionStore = SessionStore.shared
    
    var inspection: Inspections
    
    var body: some View {
        Form {
            if !inspection.photos.isEmpty {
                Section(header: Text("Фотографии".uppercased())) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(inspection.photos, id: \.id) { photo in
                                NavigationLink(destination: ImageDetail(photo: photo.path)) {
                                    WebImage(url: URL(string: photo.path), options: .scaleDownLargeImages)
                                        .resizable()
                                        .placeholder {
                                            LoadingFlowerView()
                                                .frame(width: 24, height: 24)
                                        }
                                        .frame(width: 75, height: 75)
                                        .cornerRadius(10)
                                }.buttonStyle(PlainButtonStyle())
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
                            .font(.footnote)
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
                            .font(.footnote)
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
                            .font(.footnote)
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
                            .font(.footnote)
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
                            .font(.footnote)
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
                            .font(.footnote)
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
                                .font(.footnote)
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
                                .font(.footnote)
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
                                .font(.footnote)
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
                                .font(.footnote)
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
                                .font(.footnote)
                        }
                    }
                }
            }
            Section(header: Text("Место проведения осмотра".uppercased())) {
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
                                .font(.footnote)
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
                                .font(.footnote)
                        }
                    }
                } else if sessionStore.yandexGeoState == .loading {
                    HStack {
                        LoadingFlowerView()
                            .frame(width: 24, height: 24)
                        VStack(alignment: .leading) {
                            Text("Определяем адрес осмотра")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Text("Загрузка")
                                .font(.footnote)
                        }
                    }
                }
            }
        }
        .navigationBarTitle("\(inspection.id)")
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
