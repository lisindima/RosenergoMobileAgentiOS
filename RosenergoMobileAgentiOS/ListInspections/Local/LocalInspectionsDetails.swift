//
//  LocalInspectionsDetails.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 23.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import Alamofire

struct LocalInspectionsDetails: View {
    
    @EnvironmentObject private var sessionStore: SessionStore
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject private var notificationStore = NotificationStore.shared
    
    @State private var presentMapActionSheet: Bool = false
    @State private var yandexGeoState: YandexGeoState = .loading
    @State private var yandexGeo: YandexGeo?
    
    var localInspections: LocalInspections
    
    private func loadYandexGeoResponse() {
        
        let parameters = YandexGeoParameters(
            apikey: sessionStore.apiKeyForYandexGeo,
            format: "json",
            geocode: "\(localInspections.longitude), \(localInspections.latitude)",
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
    
    private func uploadLocalInspections() {
        
        sessionStore.uploadState = .upload
        
        var localPhotoParameters: [PhotoParameters] = []
        
        for photo in localInspections.photos! {
            localPhotoParameters.append(PhotoParameters(latitude: localInspections.latitude, longitude: localInspections.longitude, file: photo, maked_photo_at: localInspections.dateInspections!))
        }
        
        let headers: HTTPHeaders = [
            .authorization(bearerToken: sessionStore.loginModel!.data.apiToken),
            .accept("application/json")
        ]
        
        let parameters = InspectionParameters(
            car_model: localInspections.carModel!,
            car_reg_number: localInspections.carRegNumber!,
            car_body_number: localInspections.carBodyNumber!,
            car_vin: localInspections.carVin!,
            insurance_contract_number: localInspections.insuranceContractNumber!,
            car_model2: localInspections.carModel2,
            car_reg_number2: localInspections.carRegNumber2,
            car_body_number2: localInspections.carBodyNumber2,
            car_vin2: localInspections.carVin2,
            insurance_contract_number2: localInspections.insuranceContractNumber2,
            latitude: localInspections.latitude,
            longitude: localInspections.longitude,
            photos: localPhotoParameters
        )
        
        AF.request(sessionStore.serverURL + "inspection", method: .post, parameters: parameters, encoder: JSONParameterEncoder.default, headers: headers)
            .validate()
            .uploadProgress { progress in
                self.sessionStore.uploadProgress = progress.fractionCompleted
            }
            .response { response in
                switch response.result {
                case .success:
                    self.presentationMode.wrappedValue.dismiss()
                    self.sessionStore.alertType = .success
                    self.sessionStore.showAlert = true
                    self.sessionStore.uploadState = .none
                    self.notificationStore.cancelNotifications(id: self.localInspections.id!.uuidString)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.moc.delete(self.localInspections)
                        do {
                            try self.moc.save()
                        } catch {
                            print(error)
                        }
                    }
                case .failure(let error):
                    self.sessionStore.alertType = .error
                    self.sessionStore.showAlert = true
                    self.sessionStore.uploadState = .none
                    print(error.errorDescription!)
            }
        }
    }
    
    var body: some View {
        VStack {
            Form {
                if !localInspections.photos!.isEmpty {
                    Section(header: Text("Фотографии").fontWeight(.bold)) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(localInspections.photos!, id: \.self) { photo in
                                    NavigationLink(destination: LocalImageDetail(photo: photo)) {
                                        Image(uiImage: UIImage(data: Data(base64Encoded: photo, options: .ignoreUnknownCharacters)!)!.resize(size: CGSize(width: 100, height: 100), scale: UIScreen.main.scale))
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
                Section(header: Text("Дата осмотра").fontWeight(.bold)) {
                    SectionItem(
                        imageName: "timer",
                        imageColor: .rosenergo,
                        subTitle: "Дата создания осмотра",
                        title: localInspections.dateInspections!.dataLocalInspection()
                    )
                }
                Section(header: Text(localInspections.carModel2 != nil ? "Первый автомобиль" : "Информация").fontWeight(.bold)) {
                    SectionItem(
                        imageName: "car",
                        imageColor: .rosenergo,
                        subTitle: "Модель автомобиля",
                        title: localInspections.carModel!
                    )
                    SectionItem(
                        imageName: "rectangle",
                        imageColor: .rosenergo,
                        subTitle: "Регистрационный номер",
                        title: localInspections.carRegNumber!
                    )
                    SectionItem(
                        imageName: "v.circle",
                        imageColor: .rosenergo,
                        subTitle: "VIN",
                        title: localInspections.carVin!
                    )
                    SectionItem(
                        imageName: "textformat.123",
                        imageColor: .rosenergo,
                        subTitle: "Номер кузова",
                        title: localInspections.carBodyNumber!
                    )
                    SectionItem(
                        imageName: "text.justify",
                        imageColor: .rosenergo,
                        subTitle: "Страховой полис",
                        title: localInspections.insuranceContractNumber!
                    )
                }
                if localInspections.carModel2 != nil {
                    Section(header: Text("Второй автомобиль").fontWeight(.bold)) {
                        SectionItem(
                            imageName: "car",
                            imageColor: .rosenergo,
                            subTitle: "Модель автомобиля",
                            title: localInspections.carModel2!
                        )
                        SectionItem(
                            imageName: "rectangle",
                            imageColor: .rosenergo,
                            subTitle: "Регистрационный номер",
                            title: localInspections.carRegNumber2!
                        )
                        SectionItem(
                            imageName: "v.circle",
                            imageColor: .rosenergo,
                            subTitle: "VIN",
                            title: localInspections.carVin2!
                        )
                        SectionItem(
                            imageName: "textformat.123",
                            imageColor: .rosenergo,
                            subTitle: "Номер кузова",
                            title: localInspections.carBodyNumber2!
                        )
                        SectionItem(
                            imageName: "text.justify",
                            imageColor: .rosenergo,
                            subTitle: "Страховой полис",
                            title: localInspections.insuranceContractNumber2!
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
            if sessionStore.uploadState == .none {
                CustomButton(label: "Отправить на сервер", colorButton: .rosenergo, colorText: .white) {
                    UIApplication.shared.hideKeyboard()
                    self.uploadLocalInspections()
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            } else if sessionStore.uploadState == .upload {
                UploadIndicator(progress: $sessionStore.uploadProgress, color: .rosenergo)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
            }
        }
        .onAppear {
            if self.yandexGeo == nil {
                self.loadYandexGeoResponse()
            }
        }
        .environment(\.horizontalSizeClass, .regular)
        .navigationBarTitle("Не отправлено")
        .actionSheet(isPresented: $presentMapActionSheet) {
            ActionSheet(title: Text("Выберите приложение"), message: Text("В каком приложение вы хотите открыть это местоположение?"), buttons: [.default(Text("Apple Maps")) {
                UIApplication.shared.open(URL(string: "https://maps.apple.com/?daddr=\(self.localInspections.latitude),\(self.localInspections.longitude)")!)
                }, .default(Text("Яндекс.Карты")) {
                UIApplication.shared.open(URL(string: "yandexmaps://maps.yandex.ru/?pt=\(self.localInspections.longitude),\(self.localInspections.latitude)")!)
                }, .cancel()
            ])
        }
        .alert(isPresented: $sessionStore.showAlert) {
            switch sessionStore.alertType {
            case .success:
                return Alert(title: Text("Успешно!"), message: Text("Осмотр успешно загружен на сервер."), dismissButton: .default(Text("Закрыть")))
            case .error:
                return Alert(title: Text("Ошибка!"), message: Text("Попробуйте загрузить осмотр позже."), dismissButton: .default(Text("Закрыть")))
            case .emptyLocation:
                return Alert(title: Text("Успешно!"), message: Text("Осмотр успешно загружен на сервер."), dismissButton: .default(Text("Закрыть")))
            case .emptyPhoto:
                return Alert(title: Text("Успешно!"), message: Text("Осмотр успешно загружен на сервер."), dismissButton: .default(Text("Закрыть")))
            case .emptyTextField:
                return Alert(title: Text("Успешно!"), message: Text("Осмотр успешно загружен на сервер."), dismissButton: .default(Text("Закрыть")))
            }
        }
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
