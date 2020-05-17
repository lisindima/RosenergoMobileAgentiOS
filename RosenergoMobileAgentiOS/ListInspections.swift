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
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(entity: LocalInspections.entity(), sortDescriptors: []) var localInspections: FetchedResults<LocalInspections>
    
    @State private var searchText: String = ""
    
    func delete(at offsets: IndexSet) {
        for offset in offsets {
            let localInspection = localInspections[offset]
            moc.delete(localInspection)
        }
        try? moc.save()
    }
    
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
                    Section(header: Text("НЕ ОТПРАВЛЕННЫЕ ОСМОТРЫ")) {
                        ForEach(localInspections.filter {
                            self.searchText.isEmpty ? true : $0.insuranceContractNumber!.localizedStandardContains(self.searchText)
                        }, id: \.id) { localInspections in
                            NavigationLink(destination: ListLocalInspectionsDetails(localInspections: localInspections)) {
                                ListLocalInspectionsItems(localInspections: localInspections)
                            }
                        }.onDelete(perform: delete)
                    }
                    Section(header: Text("ОТПРАВЛЕННЫЕ ОСМОТРЫ")) {
                        ForEach(sessionStore.inspections.filter {
                            self.searchText.isEmpty ? true : $0.insuranceContractNumber.localizedStandardContains(self.searchText)
                        }, id: \.id) { inspection in
                            NavigationLink(destination: ListInspectionsDetails(inspection: inspection)) {
                                ListInspectionsItems(inspection: inspection)
                            }
                        }
                    }
                }.listStyle(GroupedListStyle())
            }
        }
        .navigationBarTitle("Осмотры")
        .navigationBarItems(trailing: HStack {
            Button(action: {
                self.sessionStore.getInspections(apiToken: self.sessionStore.loginModel!.data.apiToken)
            }) {
                Image(systemName: "arrow.2.circlepath.circle")
                    .imageScale(.large)
            }
            NavigationLink(destination: CreateInspections()) {
                Image(systemName: "plus.circle")
                    .imageScale(.large)
            }
        })
        
    }
}

struct ListLocalInspectionsItems: View {
    
    var localInspections: LocalInspections
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Не загружено")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                Group {
                    Text("Номер полиса: \(localInspections.insuranceContractNumber!)")
                    Text("Модель авто: \(localInspections.carModel!)")
                    Text("Рег.номер: \(localInspections.carRegNumber!)")
                    Text("VIN: \(localInspections.carVin!)")
                    Text("Номер кузова: \(localInspections.carBodyNumber!)")
                }.font(.footnote)
            }
            Spacer()
        }
    }
}

struct ListLocalInspectionsDetails: View {
    
    var localInspections: LocalInspections
    
    var body: some View {
        Form {
            Section(header: Text("Информация")) {
                VStack(alignment: .leading) {
                    Text("Страховой полис")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text(localInspections.insuranceContractNumber!)
                }
                VStack(alignment: .leading) {
                    Text("Номер кузова")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text(localInspections.carBodyNumber!)
                }
                VStack(alignment: .leading) {
                    Text("Модель автомобиля")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text(localInspections.carModel!)
                }
                VStack(alignment: .leading) {
                    Text("VIN")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text(localInspections.carVin!)
                }
                VStack(alignment: .leading) {
                    Text("Регистрационный номер")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text(localInspections.carRegNumber!)
                }
            }
        }
        .environment(\.horizontalSizeClass, .regular)
        .navigationBarTitle("Не загружено")
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
    
    var body: some View {
        Form {
            if !inspection.photos.isEmpty {
                Section(header: Text("Фотографии")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(inspection.photos, id: \.id) { photo in
                                WebImage(url: URL(string: photo.path))
                                    .resizable()
                                    .indicator(.activity)
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(10)
                            }
                        }.padding(.vertical)
                    }
                }
            }
            Section(header: Text("Информация")) {
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
        }
        .environment(\.horizontalSizeClass, .regular)
        .navigationBarTitle("Осмотр: \(inspection.id)")
    }
}
