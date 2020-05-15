//
//  ListInspections.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 10.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

struct ListInspections: View {
    
    @EnvironmentObject var sessionStore: SessionStore
    
    @State private var searchText: String = ""
    
    var body: some View {
        VStack {
            if sessionStore.loginModel == nil {
                Text("Ошибка")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                Text("Попробуйте перезайти в аккаунт")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else if sessionStore.inspections.isEmpty {
                ActivityIndicator(styleSpinner: .large)
                    .onAppear {
                        self.sessionStore.getInspections(apiToken: self.sessionStore.loginModel!.data.apiToken)
                }
            } else {
                SearchBar(text: $searchText)
                    .padding(.horizontal, 6)
                List {
                    ForEach(self.sessionStore.inspections.filter {
                        self.searchText.isEmpty ? true : $0.insuranceContractNumber.localizedStandardContains(self.searchText)
                    }, id: \.id) { inspection in
                        NavigationLink(destination: ListInspectionsDetails(inspection: inspection)) {
                            ListInspectionsItems(inspection: inspection)
                        }
                    }
                }
            }
        }
        .navigationBarTitle("Осмотры")
        .navigationBarItems(trailing: Button(action: {
            self.sessionStore.getInspections(apiToken: self.sessionStore.loginModel!.data.apiToken)
        }) {
            Image(systemName: "arrow.2.circlepath.circle")
                .imageScale(.large)
        })
    }
}

struct ListInspectionsItems: View {
    
    var inspection: Inspections
    let noImageUrl = "https://via.placeholder.com/100"
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(inspection.id)")
                    .font(.title)
                    .fontWeight(.bold)
                Group {
                    Text("Номер полиса: \(inspection.insuranceContractNumber)")
                    Text("Модель авто: \(inspection.carModel)")
                    Text("Рег.номер: \(inspection.carRegNumber)")
                    Text("VIN: \(inspection.carVin)")
                    Text("Номер кузова: \(inspection.carBodyNumber)")
                }.font(.footnote)
            }
            Spacer()
            ZStack {
                WebImage(url: URL(string: inspection.photos.first?.path ?? noImageUrl))
                    .resizable()
                    .indicator(.activity)
                    .cornerRadius(10)
                    .frame(width: 100, height: 100)
                if !inspection.photos.isEmpty {
                    ZStack {
                        Circle()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.rosenergo)
                        Text("\(inspection.photos.count)")
                            .foregroundColor(.white)
                    }.offset(x: 45, y: -45)
                }
            }
        }
    }
}

struct ListInspectionsDetails: View {
    
    var inspection: Inspections
    let noImageUrl = "https://via.placeholder.com/100"
    
    var body: some View {
        VStack {
            HStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    ForEach(inspection.photos, id: \.id) { photo in
                        WebImage(url: URL(string: photo.path))
                            .resizable()
                            .indicator(.activity)
                            .frame(width: 100, height: 100)
                            .cornerRadius(10)
                    }
                }
            }.padding()
            Text(inspection.insuranceContractNumber)
            Text(inspection.carBodyNumber)
            Text(inspection.carModel)
            Text(inspection.carVin)
            Text(inspection.carVin)
            Spacer()
        }.navigationBarTitle("Осмотр: \(inspection.id)")
    }
}
