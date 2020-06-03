//
//  LocalInspectionsDetails.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 23.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import Alamofire
import SPAlert

struct LocalInspectionsDetails: View {
    
    @EnvironmentObject var sessionStore: SessionStore
    @Environment(\.managedObjectContext) var moc
    
    @State private var localPhotoParameters: [PhotoParameters] = [PhotoParameters]()
    
    var localInspections: LocalInspections
    
    let serverURL: String = "https://rosenergo.calcn1.ru/api/"
    
    func preparationPhotoArray() {
        if !localInspections.photos!.isEmpty {
            for photo in localInspections.photos! {
                localPhotoParameters.append(PhotoParameters(latitude: localInspections.latitude, longitude: localInspections.longitude, file: photo, maked_photo_at: localInspections.dateInspections!))
            }
        }
    }
    
    func uploadLocalInspections(carModel: String, carRegNumber: String, carBodyNumber: String, carVin: String, insuranceContractNumber: String, carModel2: String?, carRegNumber2: String?, carBodyNumber2: String?, carVin2: String?, insuranceContractNumber2: String?, latitude: Double, longitude: Double, photoParameters: [PhotoParameters], localInspections: LocalInspections) {
        
        sessionStore.uploadState = .upload
        
        let headers: HTTPHeaders = [
            .authorization(bearerToken: sessionStore.loginModel!.data.apiToken),
            .accept("application/json")
        ]
        
        let parameters = InspectionParameters(
            car_model: carModel,
            car_reg_number: carRegNumber,
            car_body_number: carBodyNumber,
            car_vin: carVin,
            insurance_contract_number: insuranceContractNumber,
            car_model2: carModel2,
            car_reg_number2: carRegNumber2,
            car_body_number2: carBodyNumber2,
            car_vin2: carVin2,
            insurance_contract_number2: insuranceContractNumber2,
            latitude: latitude,
            longitude: longitude,
            photos: photoParameters
        )
        
        AF.request(serverURL + "inspection", method: .post, parameters: parameters, encoder: JSONParameterEncoder.default, headers: headers)
            .validate()
            .response { response in
                switch response.result {
                case .success:
                    SPAlert.present(title: "Успешно!", message: "Осмотр успешно загружен на сервер.", preset: .done)
                    self.sessionStore.uploadState = .none
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.moc.delete(localInspections)
                        do {
                            try self.moc.save()
                        } catch {
                            print(error)
                        }
                    }
                case .failure(let error):
                    SPAlert.present(title: "Ошибка!", message: "Попробуйте сохранить осмотр и загрузить его позднее.", preset: .error)
                    self.sessionStore.uploadState = .none
                    print(error.errorDescription!)
            }
        }
    }
    
    var body: some View {
        VStack {
            Form {
                if !localInspections.photos!.isEmpty {
                    Section(header: Text("Фотографии".uppercased())) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(localInspections.photos!, id: \.self) { photo in
                                    NavigationLink(destination: LocalImageDetail(photo: photo)) {
                                        Image(uiImage: UIImage(data: Data.init(base64Encoded: photo, options: .ignoreUnknownCharacters)!)!)
                                            .renderingMode(.original)
                                            .resizable()
                                            .frame(width: 100, height: 100)
                                            .cornerRadius(10)
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
                        Text(localInspections.dateInspections!.dataLocalInspection())
                    }
                }
                Section(header: Text(localInspections.carModel2 != nil ? "Первый автомобиль".uppercased() : "Информация".uppercased())) {
                    HStack {
                        Image(systemName: "car")
                            .frame(width: 24)
                            .foregroundColor(.rosenergo)
                        VStack(alignment: .leading) {
                            Text("Модель автомобиля")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Text(localInspections.carModel!)
                        }
                    }
                    HStack {
                        Image(systemName: "number")
                            .frame(width: 24)
                            .foregroundColor(.rosenergo)
                        VStack(alignment: .leading) {
                            Text("Регистрационный номер")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Text(localInspections.carRegNumber!)
                        }
                    }
                    HStack {
                        Image(systemName: "map")
                            .frame(width: 24)
                            .foregroundColor(.rosenergo)
                        VStack(alignment: .leading) {
                            Text("VIN")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Text(localInspections.carVin!)
                        }
                    }
                    HStack {
                        Image(systemName: "map")
                            .frame(width: 24)
                            .foregroundColor(.rosenergo)
                        VStack(alignment: .leading) {
                            Text("Номер кузова")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Text(localInspections.carBodyNumber!)
                        }
                    }
                    HStack {
                        Image(systemName: "list.bullet.below.rectangle")
                            .frame(width: 24)
                            .foregroundColor(.rosenergo)
                        VStack(alignment: .leading) {
                            Text("Страховой полис")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Text(localInspections.insuranceContractNumber!)
                        }
                    }
                }
                if localInspections.carModel2 != nil {
                    Section(header: Text("Второй автомобиль".uppercased())) {
                        HStack {
                            Image(systemName: "car")
                                .frame(width: 24)
                                .foregroundColor(.rosenergo)
                            VStack(alignment: .leading) {
                                Text("Модель автомобиля")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                                Text(localInspections.carModel2!)
                            }
                        }
                        HStack {
                            Image(systemName: "number")
                                .frame(width: 24)
                                .foregroundColor(.rosenergo)
                            VStack(alignment: .leading) {
                                Text("Регистрационный номер")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                                Text(localInspections.carRegNumber2!)
                            }
                        }
                        HStack {
                            Image(systemName: "map")
                                .frame(width: 24)
                                .foregroundColor(.rosenergo)
                            VStack(alignment: .leading) {
                                Text("VIN")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                                Text(localInspections.carVin2!)
                            }
                        }
                        HStack {
                            Image(systemName: "map")
                                .frame(width: 24)
                                .foregroundColor(.rosenergo)
                            VStack(alignment: .leading) {
                                Text("Номер кузова")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                                Text(localInspections.carBodyNumber2!)
                            }
                        }
                        HStack {
                            Image(systemName: "list.bullet.below.rectangle")
                                .frame(width: 24)
                                .foregroundColor(.rosenergo)
                            VStack(alignment: .leading) {
                                Text("Страховой полис")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                                Text(localInspections.insuranceContractNumber2!)
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
                            }
                        }
                    }
                    MapView(latitude: localInspections.latitude, longitude: localInspections.longitude)
                        .cornerRadius(10)
                        .padding(.vertical, 8)
                        .frame(minWidth: nil, idealWidth: nil, maxWidth: .infinity, minHeight: 300, idealHeight: 300, maxHeight: 300)
                }
            }
            if sessionStore.uploadState == .none {
                CustomButton(label: "Отправить на сервер", colorButton: .rosenergo, colorText: .white) {
                    self.uploadLocalInspections(
                        carModel: self.localInspections.carModel!,
                        carRegNumber: self.localInspections.carRegNumber!,
                        carBodyNumber: self.localInspections.carBodyNumber!,
                        carVin: self.localInspections.carVin!,
                        insuranceContractNumber: self.localInspections.insuranceContractNumber!,
                        carModel2: self.localInspections.carModel2,
                        carRegNumber2: self.localInspections.carRegNumber2,
                        carBodyNumber2: self.localInspections.carBodyNumber2,
                        carVin2: self.localInspections.carVin2,
                        insuranceContractNumber2: self.localInspections.insuranceContractNumber2,
                        latitude: self.localInspections.latitude,
                        longitude: self.localInspections.longitude,
                        photoParameters: self.localPhotoParameters,
                        localInspections: self.localInspections
                    )
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            } else if sessionStore.uploadState == .upload {
                HStack {
                    Spacer()
                    ActivityIndicatorButton()
                    Spacer()
                }
                .padding()
                .background(Color.rosenergo)
                .cornerRadius(8)
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
        }
        .onAppear {
            self.preparationPhotoArray()
            self.sessionStore.loadYandexGeoResponse(latitude: self.localInspections.latitude, longitude: self.localInspections.longitude)
        }
        .onDisappear {
            self.localPhotoParameters.removeAll()
            self.sessionStore.yandexGeo = nil
            self.sessionStore.yandexGeoState = .loading
            print("ОЧИЩАЕМ")
        }
        .environment(\.horizontalSizeClass, .regular)
        .navigationBarTitle("Не отправлено")
    }
}

extension String {
    func dataLocalInspection() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: self)
        let newDateFormatter = DateFormatter()
        newDateFormatter.dateFormat = "dd MMM yyyy, HH:mm"
        let stringDate = newDateFormatter.string(from: date!)
        return stringDate
    }
}
