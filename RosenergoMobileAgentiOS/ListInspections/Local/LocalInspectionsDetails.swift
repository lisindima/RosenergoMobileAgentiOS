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
    
    @EnvironmentObject var sessionStore: SessionStore
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var notificationStore: NotificationStore = NotificationStore.shared
    
    @State private var presentMapActionSheet: Bool = false
    @State private var yandexGeoState: YandexGeoState = .loading
    @State private var yandexGeo: YandexGeo?
    
    var localInspections: LocalInspections
    
    private func delete() {
        notificationStore.cancelNotifications(id: localInspections.id!.uuidString)
        presentationMode.wrappedValue.dismiss()
        moc.delete(localInspections)
        do {
            try moc.save()
        } catch {
            print(error)
        }
    }
    
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
                    guard let yandexGeoResponse = response.value else { return }
                    yandexGeo = yandexGeoResponse
                    yandexGeoState = .success
                case .failure(let error):
                    print(error)
                    yandexGeoState = .failure
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
                sessionStore.uploadProgress = progress.fractionCompleted
            }
            .response { response in
                switch response.result {
                case .success:
                    sessionStore.uploadState = .none
                    sessionStore.alertType = .success
                    sessionStore.showAlert = true
                case .failure(let error):
                    sessionStore.errorAlert = error.errorDescription
                    sessionStore.uploadState = .none
                    sessionStore.alertType = .error
                    sessionStore.showAlert = true
                    print(error.errorDescription!)
            }
        }
    }
    
    var body: some View {
        VStack {
            Form {
                if localInspections.photos != nil {
                    Section(header: Text("Фотографии".uppercased())) {
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
                if localInspections.dateInspections != nil {
                    Section(header: Text("Дата осмотра".uppercased())) {
                        HStack {
                            Image(systemName: "timer")
                                .frame(width: 24)
                                .foregroundColor(.rosenergo)
                            VStack(alignment: .leading) {
                                Text(localInspections.dateInspections!.dataLocalInspection())
                            }
                        }
                    }
                }
                if localInspections.carModel != nil {
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
                            Image(systemName: "rectangle")
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
                            Image(systemName: "v.circle")
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
                            Image(systemName: "textformat.123")
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
                            Image(systemName: "text.justify")
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
                            Image(systemName: "rectangle")
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
                            Image(systemName: "v.circle")
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
                            Image(systemName: "textformat.123")
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
                            Image(systemName: "text.justify")
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
            if sessionStore.uploadState == .none {
                CustomButton(label: "Отправить на сервер", colorButton: .rosenergo, colorText: .white) {
                    UIApplication.shared.hideKeyboard()
                    uploadLocalInspections()
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
            if yandexGeo == nil {
                loadYandexGeoResponse()
            }
        }
        .environment(\.horizontalSizeClass, .regular)
        .navigationBarTitle("Не отправлено")
        .actionSheet(isPresented: $presentMapActionSheet) {
            ActionSheet(title: Text("Выберите приложение"), message: Text("В каком приложение вы хотите открыть это местоположение?"), buttons: [.default(Text("Apple Maps")) {
                UIApplication.shared.open(URL(string: "https://maps.apple.com/?daddr=\(localInspections.latitude),\(localInspections.longitude)")!)
                }, .default(Text("Яндекс.Карты")) {
                UIApplication.shared.open(URL(string: "yandexmaps://maps.yandex.ru/?pt=\(localInspections.longitude),\(localInspections.latitude)")!)
                }, .cancel()
            ])
        }
        .alert(isPresented: $sessionStore.showAlert) {
            switch sessionStore.alertType {
            case .success:
                return Alert(title: Text("Успешно"), message: Text("Осмотр успешно загружен на сервер."), dismissButton: .default(Text("Закрыть"), action: delete))
            case .error:
                return Alert(title: Text("Ошибка"), message: Text("Попробуйте загрузить осмотр позже.\n\(sessionStore.errorAlert ?? "")"), dismissButton: .default(Text("Закрыть")))
            case .emptyLocation:
                return Alert(title: Text("Успешно"), message: Text("Осмотр успешно загружен на сервер."), dismissButton: .default(Text("Закрыть"), action: delete))
            case .emptyPhoto:
                return Alert(title: Text("Успешно"), message: Text("Осмотр успешно загружен на сервер."), dismissButton: .default(Text("Закрыть"), action: delete))
            case .emptyTextField:
                return Alert(title: Text("Успешно"), message: Text("Осмотр успешно загружен на сервер."), dismissButton: .default(Text("Закрыть"), action: delete))
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
