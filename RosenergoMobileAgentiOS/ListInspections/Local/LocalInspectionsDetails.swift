//
//  LocalInspectionsDetails.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 23.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct LocalInspectionsDetails: View {
    
    @EnvironmentObject var sessionStore: SessionStore
    
    @State private var localPhotoParameters: [PhotoParameters] = [PhotoParameters]()
    
    func preparationPhotoArray() {
        if !localInspections.photos!.isEmpty {
            for photo in localInspections.photos! {
                localPhotoParameters.append(PhotoParameters(latitude: localInspections.latitude, longitude: localInspections.longitude, file: photo, maked_photo_at: localInspections.dateInspections!))
            }
        }
    }
    
    var localInspections: LocalInspections
    
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
                    Text(localInspections.dateInspections!.dataLocalInspection())
                }
                Section(header: Text(localInspections.carModel2 != nil ? "Первый автомобиль".uppercased() : "Информация".uppercased())) {
                    VStack(alignment: .leading) {
                        Text("Модель автомобиля")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Text(localInspections.carModel!)
                    }
                    VStack(alignment: .leading) {
                        Text("Регистрационный номер")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Text(localInspections.carRegNumber!)
                    }
                    VStack(alignment: .leading) {
                        Text("VIN")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Text(localInspections.carVin!)
                    }
                    VStack(alignment: .leading) {
                        Text("Номер кузова")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Text(localInspections.carBodyNumber!)
                    }
                    VStack(alignment: .leading) {
                        Text("Страховой полис")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Text(localInspections.insuranceContractNumber!)
                    }
                }
                if localInspections.carModel2 != nil {
                    Section(header: Text("Второй автомобиль".uppercased())) {
                        VStack(alignment: .leading) {
                            Text("Модель автомобиля")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Text(localInspections.carModel2!)
                        }
                        VStack(alignment: .leading) {
                            Text("Регистрационный номер")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Text(localInspections.carRegNumber2!)
                        }
                        VStack(alignment: .leading) {
                            Text("VIN")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Text(localInspections.carVin2!)
                        }
                        VStack(alignment: .leading) {
                            Text("Номер кузова")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Text(localInspections.carBodyNumber2!)
                        }
                        VStack(alignment: .leading) {
                            Text("Страховой полис")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Text(localInspections.insuranceContractNumber2!)
                        }
                    }
                }
                Section(header: Text("Место проведения осмотра".uppercased())) {
                    MapView(latitude: localInspections.latitude, longitude: localInspections.longitude)
                        .cornerRadius(10)
                        .padding(.vertical, 8)
                        .frame(minWidth: nil, idealWidth: nil, maxWidth: .infinity, minHeight: 300, idealHeight: 300, maxHeight: 300)
                }
            }
            if sessionStore.inspectionUploadState == .none {
                CustomButton(label: "Отправить на сервер", colorButton: .rosenergo, colorText: .white) {
                    self.sessionStore.uploadInspections(
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
                        photoParameters: self.localPhotoParameters
                    )
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            } else if sessionStore.inspectionUploadState == .upload {
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
        .onAppear(perform: preparationPhotoArray)
        .onDisappear {
            self.localPhotoParameters.removeAll()
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
        newDateFormatter.dateFormat = "dd MMM yyyy HH:mm"
        newDateFormatter.locale = Locale(identifier: "ru_RU")
        let stringDate = newDateFormatter.string(from: date!)
        return stringDate
    }
}
