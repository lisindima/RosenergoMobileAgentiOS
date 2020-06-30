//
//  ListInspections.swift
//  RosenergoMobileAgentwatchOS Extension
//
//  Created by Дмитрий Лисин on 15.06.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct ListInspections: View {
    
    @EnvironmentObject var sessionStore: SessionStore
    @State private var searchText: String = ""
    
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(entity: LocalInspections.entity(), sortDescriptors: []) var localInspections: FetchedResults<LocalInspections>
    
    func delete(at offsets: IndexSet) {
        for offset in offsets {
            let localInspection = localInspections[offset]
            moc.delete(localInspection)
        }
        try? moc.save()
    }
    
    var body: some View {
        Group {
            if sessionStore.inspections.isEmpty && localInspections.isEmpty && sessionStore.inspectionsLoadingState == .failure {
                Text("Нет подключения к интернету!")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            } else if sessionStore.inspections.isEmpty && localInspections.isEmpty && sessionStore.inspectionsLoadingState == .success {
                Text("Нет осмотров")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                Text("Добавьте свой первый осмотр и он отобразиться здесь.")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            } else if sessionStore.inspections.isEmpty && localInspections.isEmpty && sessionStore.inspectionsLoadingState == .loading {
                ProgressView()
            } else {
                List {
                    Section {
                        TextField("Поиск", text: $searchText)
                    }
                    if !localInspections.isEmpty {
                        Section(header: Text("Не отправленные осмотры").fontWeight(.bold)) {
                            ForEach(localInspections.filter {
                                searchText.isEmpty || $0.insuranceContractNumber!.localizedStandardContains(searchText)
                            }, id: \.id) { localInspections in
                                NavigationLink(destination: LocalInspectionsDetails(localInspections: localInspections).environmentObject(sessionStore)) {
                                    LocalInspectionsItems(localInspections: localInspections)
                                }
                            }.onDelete(perform: delete)
                        }
                    }
                    if !sessionStore.inspections.isEmpty {
                        Section(header: Text("Отправленные осмотры").fontWeight(.bold)) {
                            ForEach(sessionStore.inspections.reversed().filter {
                                searchText.isEmpty || $0.insuranceContractNumber.localizedStandardContains(searchText)
                            }, id: \.id) { inspection in
                                NavigationLink(destination: InspectionsDetails(inspection: inspection).environmentObject(sessionStore)) {
                                    InspectionsItems(inspection: inspection)
                                }
                            }
                        }
                    }
                }
            }
        }
        .onAppear(perform: sessionStore.getInspections)
        .navigationBarTitle("Осмотры")
    }
}

struct ListInspections_Previews: PreviewProvider {
    static var previews: some View {
        ListInspections()
    }
}
