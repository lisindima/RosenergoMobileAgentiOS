//
//  ListInspections.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 10.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import NativeSearchBar
import SDWebImageSwiftUI

struct ListInspections: View {
    
    @EnvironmentObject var sessionStore: SessionStore
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(entity: LocalInspections.entity(), sortDescriptors: []) var localInspections: FetchedResults<LocalInspections>
    
    @ObservedObject var searchBar: SearchBar = SearchBar.shared
    
    func delete(at offsets: IndexSet) {
        for offset in offsets {
            let localInspection = localInspections[offset]
            moc.delete(localInspection)
        }
        try? moc.save()
    }
    
    var body: some View {
        VStack {
            if sessionStore.inspections.isEmpty && localInspections.isEmpty && sessionStore.inspectionsLoadingState == .failure {
                Text("Нет подключения к интернету!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            } else if sessionStore.inspections.isEmpty && localInspections.isEmpty && sessionStore.inspectionsLoadingState == .success {
                Text("Нет осмотров!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            } else if sessionStore.inspections.isEmpty && localInspections.isEmpty && sessionStore.inspectionsLoadingState == .loading {
                ActivityIndicator(styleSpinner: .large)
            } else {
                List {
                    if !localInspections.isEmpty {
                        Section(header: Text("НЕ ОТПРАВЛЕННЫЕ ОСМОТРЫ")) {
                            ForEach(localInspections.filter {
                                searchBar.text.isEmpty || $0.insuranceContractNumber!.localizedStandardContains(searchBar.text)
                            }, id: \.id) { localInspections in
                                NavigationLink(destination: ListLocalInspectionsDetails(localInspections: localInspections)) {
                                    ListLocalInspectionsItems(localInspections: localInspections)
                                }
                            }.onDelete(perform: delete)
                        }
                    }
                    if !sessionStore.inspections.isEmpty {
                        Section(header: Text("ОТПРАВЛЕННЫЕ ОСМОТРЫ")) {
                            ForEach(sessionStore.inspections.filter {
                                searchBar.text.isEmpty || $0.insuranceContractNumber.localizedStandardContains(searchBar.text)
                            }, id: \.id) { inspection in
                                NavigationLink(destination: ListInspectionsDetails(inspection: inspection)) {
                                    ListInspectionsItems(inspection: inspection)
                                }
                            }
                        }
                    }
                }
                .listStyle(GroupedListStyle())
                .addSearchBar(searchBar)
            }
        }
        .onAppear {
            self.sessionStore.getInspections()
        }
        .navigationBarTitle("Осмотры")
        .navigationBarItems(trailing: HStack {
            Button(action: {
                self.sessionStore.getInspections()
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
                }
                .font(.footnote)
                .foregroundColor(.secondary)
            }
            Spacer()
            if localInspections.photos != nil {
                ZStack {
                    Image(uiImage: UIImage(data: (localInspections.photos!.first!))!)
                        .resizable()
                        .cornerRadius(10)
                        .frame(width: 100, height: 100)
                    ZStack {
                        Circle()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.rosenergo)
                        Text("\(localInspections.photos!.count)")
                            .foregroundColor(.white)
                    }.offset(x: 45, y: -45)
                }
            }
        }
    }
}

struct ListLocalInspectionsDetails: View {
    
    var localInspections: LocalInspections
    
    var body: some View {
        VStack {
            Form {
                if localInspections.photos != nil {
                    Section(header: Text("Фотографии")) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(localInspections.photos!, id: \.self) { photo in
                                    Image(uiImage: UIImage(data: photo)!)
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                        .cornerRadius(10)
                                }
                            }.padding(.vertical)
                        }
                    }
                }
                Section(header: Text(localInspections.carModel2 != nil ? "Первый автомобиль" : "Информация")) {
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
                if localInspections.carModel2 != nil {
                    Section(header: Text("Второй автомобиль")) {
                        VStack(alignment: .leading) {
                            Text("Страховой полис")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Text(localInspections.insuranceContractNumber2!)
                        }
                        VStack(alignment: .leading) {
                            Text("Номер кузова")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Text(localInspections.carBodyNumber2!)
                        }
                        VStack(alignment: .leading) {
                            Text("Модель автомобиля")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Text(localInspections.carModel2!)
                        }
                        VStack(alignment: .leading) {
                            Text("VIN")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Text(localInspections.carVin2!)
                        }
                        VStack(alignment: .leading) {
                            Text("Регистрационный номер")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Text(localInspections.carRegNumber2!)
                        }
                    }
                }
                Section(header: Text("Место проведения осмотра")) {
                    MapView(latitude: localInspections.latitude, longitude: localInspections.longitude)
                        .cornerRadius(10)
                        .frame(minWidth: nil, idealWidth: nil, maxWidth: .infinity, minHeight: 300, idealHeight: 300, maxHeight: 300)
                }
            }
            CustomButton(label: "Отправить на сервер", colorButton: .rosenergo, colorText: .white) {
                print("Отправить на сервер")
            }.padding(.horizontal)
        }
        .environment(\.horizontalSizeClass, .regular)
        .navigationBarTitle("Не загружено")
    }
}

struct ListInspectionsItems: View {
    
    var inspection: Inspections
    
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
                }
                .font(.footnote)
                .foregroundColor(.secondary)
                if inspection.carModel2 != nil {
                    Divider()
                    Group {
                        Text("Номер полиса: \(inspection.insuranceContractNumber2!)")
                        Text("Модель авто: \(inspection.carModel2!)")
                        Text("Рег.номер: \(inspection.carRegNumber2!)")
                        Text("VIN: \(inspection.carVin2!)")
                        Text("Номер кузова: \(inspection.carBodyNumber2!)")
                    }
                    .font(.footnote)
                    .foregroundColor(.secondary)
                }
            }
            Spacer()
            if !inspection.photos.isEmpty {
                ZStack {
                    WebImage(url: URL(string: inspection.photos.first!.path))
                        .resizable()
                        .indicator(.activity)
                        .cornerRadius(10)
                        .frame(width: 100, height: 100)
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
            Section(header: Text(inspection.carModel2 != nil ? "Первый автомобиль" : "Информация")) {
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
                Section(header: Text("Второй автомобиль")) {
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
            Section(header: Text("Место проведения осмотра")) {
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
