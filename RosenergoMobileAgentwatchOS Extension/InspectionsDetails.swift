//
//  InspectionsDetails.swift
//  RosenergoMobileAgentwatchOS Extension
//
//  Created by Дмитрий Лисин on 16.06.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import URLImage
import Alamofire

struct InspectionsDetails: View {
    
    @ObservedObject var sessionStore: SessionStore = SessionStore.shared
    
    @State private var yandexGeoState: YandexGeoState = .loading
    @State private var yandexGeo: YandexGeo?
    
    var inspection: Inspections
    
    private func loadYandexGeoResponse(latitude: Double, longitude: Double) {
        
        let parameters = YandexGeoParameters(
            apikey: sessionStore.apiKeyForYandexGeo,
            format: "json",
            geocode: "\(longitude), \(latitude)",
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
    
    var body: some View {
        Form {
            if !inspection.photos.isEmpty {
                Section(header: Text("Фотографии").fontWeight(.bold)) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(inspection.photos, id: \.id) { photo in
                                NavigationLink(destination: ImageDetail(photo: photo.path)) {
                                    URLImage(URL(string: photo.path)!, processors: [Resize(size: CGSize(width: 75.0, height: 75.0), scale: WKInterfaceDevice.current().screenScale)], placeholder: { _ in
                                        ProgressView()
                                    }) { proxy in
                                        proxy.image
                                            .resizable()
                                    }
                                    .frame(width: 75, height: 75)
                                    .cornerRadius(10)
                                }.buttonStyle(PlainButtonStyle())
                            }
                        }.padding(.vertical, 8)
                    }
                }
            }
            Section(header: Text("Дата осмотра").fontWeight(.bold)) {
                HStack {
                    Image(systemName: "timer")
                        .frame(width: 24)
                        .foregroundColor(.purple)
                    VStack(alignment: .leading) {
                        Text("Дата загрузки осмотра")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Text(inspection.createdat.dataInspection())
                            .font(.footnote)
                    }
                }
            }
            Section(header: Text(inspection.carModel2 != nil ? "Первый автомобиль" : "Информация").fontWeight(.bold)) {
                HStack {
                    Image(systemName: "car")
                        .frame(width: 24)
                        .foregroundColor(.purple)
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
                        .foregroundColor(.purple)
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
                        .foregroundColor(.purple)
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
                        .foregroundColor(.purple)
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
                        .foregroundColor(.purple)
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
                Section(header: Text("Второй автомобиль").fontWeight(.bold)) {
                    HStack {
                        Image(systemName: "car")
                            .frame(width: 24)
                            .foregroundColor(.purple)
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
                            .foregroundColor(.purple)
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
                            .foregroundColor(.purple)
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
                            .foregroundColor(.purple)
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
                            .foregroundColor(.purple)
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
            Section(header: Text("Место проведения осмотра").fontWeight(.bold)) {
                if yandexGeoState == .success && yandexGeo?.response.geoObjectCollection.featureMember.first?.geoObject.metaDataProperty.geocoderMetaData.text != nil {
                    HStack {
                        Image(systemName: "map")
                            .frame(width: 24)
                            .foregroundColor(.purple)
                        VStack(alignment: .leading) {
                            Text("Адрес места проведения осмотра")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Text(yandexGeo!.response.geoObjectCollection.featureMember.first!.geoObject.metaDataProperty.geocoderMetaData.text!)
                                .font(.footnote)
                        }
                    }
                } else if yandexGeoState == .failure {
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
                } else if yandexGeoState == .loading {
                    HStack {
                        ProgressView()
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
            if self.yandexGeo == nil {
                self.loadYandexGeoResponse(latitude: self.inspection.latitude, longitude: self.inspection.longitude)
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
