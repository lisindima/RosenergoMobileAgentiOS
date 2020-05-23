//
//  InspectionsDetails.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 23.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

struct InspectionsDetails: View {
    
    var inspection: Inspections
    
    var body: some View {
        Form {
            if !inspection.photos.isEmpty {
                Section(header: Text("Фотографии".uppercased())) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(inspection.photos, id: \.id) { photo in
                                WebImage(url: URL(string: photo.path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!))
                                    .resizable()
                                    .indicator(.activity)
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(10)
                            }
                        }.padding(.vertical, 8)
                    }
                }
            }
            Section(header: Text(inspection.carModel2 != nil ? "Первый автомобиль".uppercased() : "Информация".uppercased())) {
                VStack(alignment: .leading) {
                    Text("Страховой полис")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text(inspection.insuranceContractNumber)
                }
                VStack(alignment: .leading) {
                    Text("Номер кузова")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text(inspection.carBodyNumber)
                }
                VStack(alignment: .leading) {
                    Text("Модель автомобиля")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text(inspection.carModel)
                }
                VStack(alignment: .leading) {
                    Text("VIN")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text(inspection.carVin)
                }
                VStack(alignment: .leading) {
                    Text("Регистрационный номер")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text(inspection.carRegNumber)
                }
            }
            if inspection.carModel2 != nil {
                Section(header: Text("Второй автомобиль".uppercased())) {
                    VStack(alignment: .leading) {
                        Text("Страховой полис")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Text(inspection.insuranceContractNumber2!)
                    }
                    VStack(alignment: .leading) {
                        Text("Номер кузова")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Text(inspection.carBodyNumber2!)
                    }
                    VStack(alignment: .leading) {
                        Text("Модель автомобиля")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Text(inspection.carModel2!)
                    }
                    VStack(alignment: .leading) {
                        Text("VIN")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Text(inspection.carVin2!)
                    }
                    VStack(alignment: .leading) {
                        Text("Регистрационный номер")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Text(inspection.carRegNumber2!)
                    }
                }
            }
            Section(header: Text("Место проведения осмотра".uppercased())) {
                MapView(latitude: inspection.latitude, longitude: inspection.longitude)
                    .cornerRadius(10)
                    .padding(.vertical, 8)
                    .frame(minWidth: nil, idealWidth: nil, maxWidth: .infinity, minHeight: 300, idealHeight: 300, maxHeight: 300)
            }
        }
        .environment(\.horizontalSizeClass, .regular)
        .navigationBarTitle("Осмотр: \(inspection.id)")
    }
}