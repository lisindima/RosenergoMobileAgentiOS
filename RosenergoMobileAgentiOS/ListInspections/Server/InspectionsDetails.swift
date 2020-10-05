//
//  InspectionsDetails.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 23.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import Alamofire
import SwiftUI
import URLImage

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
                    guard let yandexGeoResponse = response.value else { return }
                    yandexGeo = yandexGeoResponse
                    yandexGeoState = .success
                case let .failure(error):
                    print(error)
                    yandexGeoState = .failure
                }
        }
    }
    
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
                    presentMapActionSheet = true
                }) {
                    if yandexGeoState == .success && yandexGeo?.response.geoObjectCollection.featureMember.first?.geoObject.metaDataProperty.geocoderMetaData.text != nil {
                        HStack {
                            Image(systemName: "map")
                                .frame(width: 24)
                                .foregroundColor(.rosenergo)
                            VStack(alignment: .leading) {
                                Text(yandexGeo!.response.geoObjectCollection.featureMember.first!.geoObject.metaDataProperty.geocoderMetaData.text!)
                                    .foregroundColor(.primary)
                            }
                        }
                    } else if yandexGeoState == .failure {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .frame(width: 24)
                                .foregroundColor(.yellow)
                            VStack(alignment: .leading) {
                                Text("Проверьте подключение к интернету!")
                                    .foregroundColor(.primary)
                            }
                        }
                    } else if yandexGeoState == .loading {
                        HStack {
                            ActivityIndicator(styleSpinner: .medium)
                                .frame(width: 24)
                            VStack(alignment: .leading) {
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
                UIApplication.shared.open(URL(string: "https://maps.apple.com/?daddr=\(inspection.latitude),\(inspection.longitude)")!)
                }, .default(Text("Яндекс.Карты")) {
                    UIApplication.shared.open(URL(string: "yandexmaps://maps.yandex.ru/?pt=\(inspection.longitude),\(inspection.latitude)")!)
                }, .cancel()])
        }
        .onAppear {
            if yandexGeo == nil {
                loadYandexGeoResponse()
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
