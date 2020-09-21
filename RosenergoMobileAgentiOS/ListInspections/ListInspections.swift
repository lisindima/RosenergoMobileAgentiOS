//
//  ListInspections.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 10.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import NativeSearchBar
import SwiftUI

struct ListInspections: View {
    @Environment(\.managedObjectContext) private var moc
    
    @StateObject private var searchBar = SearchBar.shared
    
    @EnvironmentObject private var sessionStore: SessionStore
    @EnvironmentObject private var notificationStore: NotificationStore
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \LocalInspections.dateInspections, ascending: true)],
        animation: .default
    )
    private var localInspections: FetchedResults<LocalInspections>
    
    private func delete(offsets: IndexSet) {
        for offset in offsets {
            let localInspection = localInspections[offset]
            moc.delete(localInspection)
            notificationStore.cancelNotifications(localInspection.id.uuidString)
        }
        do {
            try moc.save()
        } catch {
            log(error.localizedDescription)
        }
    }
    
    var body: some View {
        #if os(watchOS)
        inspections
        #else
        inspections
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink(destination: CreateInspections()) {
                        Image(systemName: "plus.circle.fill")
                            .imageScale(.large)
                    }
                }
            }
        #endif
    }
    
    var inspections: some View {
        LoadingView(sessionStore.inspectionsLoadingState, title: "Нет осмотров", subTitle: "Добавьте свой первый осмотр и он отобразиться здесь.") { inspectionsModel in
            List {
                if !localInspections.isEmpty {
                    Section(header: Text("Не отправленные осмотры").fontWeight(.bold)) {
                        ForEach(localInspections.filter {
                            searchBar.text.isEmpty || $0.insuranceContractNumber.localizedStandardContains(searchBar.text)
                        }, id: \.id) { localInspections in
                            NavigationLink(destination: LocalInspectionsDetails(localInspections: localInspections)) {
                                LocalInspectionsItems(localInspections: localInspections)
                            }
                        }.onDelete(perform: delete)
                    }
                }
                Section(header: Text("Отправленные осмотры").fontWeight(.bold)) {
                    ForEach(inspectionsModel.filter {
                        searchBar.text.isEmpty || $0.insuranceContractNumber.localizedStandardContains(searchBar.text)
                    }, id: \.id) { inspection in
                        NavigationLink(destination: InspectionsDetails(inspection: inspection)) {
                            InspectionsItems(inspection: inspection)
                        }
                    }
                }
            }
            .addSearchBar(searchBar)
            .modifier(ListStyle())
        }
        .onAppear(perform: sessionStore.getInspections)
        .navigationTitle("Осмотры")
    }
}
