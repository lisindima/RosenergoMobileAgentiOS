//
//  VyplatnyedelaDetails.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 31.07.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import URLImage

struct VyplatnyedelaDetails: View {
    
    var vyplatnyedela: Vyplatnyedela
    
    var body: some View {
        Form {
            if !vyplatnyedela.photos.isEmpty {
                Section(header: Text("Фотографии".uppercased())) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(vyplatnyedela.photos, id: \.id) { photo in
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
            Section(header: Text("Дата загрузки выплатного дела".uppercased())) {
                HStack {
                    Image(systemName: "timer")
                        .frame(width: 24)
                        .foregroundColor(.rosenergo)
                    VStack(alignment: .leading) {
                        Text(vyplatnyedela.createdAt.dataInspection())
                    }
                }
            }
            Section(header: Text("Информация".uppercased())) {
                HStack {
                    Image(systemName: "car")
                        .frame(width: 24)
                        .foregroundColor(.rosenergo)
                    VStack(alignment: .leading) {
                        Text("Номер заявления")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Text(vyplatnyedela.numberZayavlenia)
                    }
                }
                HStack {
                    Image(systemName: "rectangle")
                        .frame(width: 24)
                        .foregroundColor(.rosenergo)
                    VStack(alignment: .leading) {
                        Text("Номер полиса")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Text(vyplatnyedela.insuranceContractNumber)
                    }
                }
            }
        }
        .environment(\.horizontalSizeClass, .regular)
        .navigationBarTitle("Дело: \(vyplatnyedela.id)")
    }
}
