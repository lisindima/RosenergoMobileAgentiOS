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
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \LocalInspections.dateInspections, ascending: true)],
        animation: .default
    )
    private var localInspections: FetchedResults<LocalInspections>
    
    #if !os(watchOS)
    @EnvironmentObject private var notificationStore: NotificationStore
    #endif
    
    private func delete(offsets: IndexSet) {
        for offset in offsets {
            let localInspection = localInspections[offset]
            moc.delete(localInspection)
            #if !os(watchOS)
            notificationStore.cancelNotifications(id: localInspection.id!.uuidString)
            #endif
        }
        do {
            try moc.save()
        } catch {
            let nsError = error as NSError
            log("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    var listInspections: some View {
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
            if !sessionStore.inspections.isEmpty {
                Section(header: Text("Отправленные осмотры").fontWeight(.bold)) {
                    ForEach(sessionStore.inspections.reversed().filter {
                        searchBar.text.isEmpty || $0.insuranceContractNumber.localizedStandardContains(searchBar.text)
                    }, id: \.id) { inspection in
                        NavigationLink(destination: InspectionsDetails(inspection: inspection)) {
                            InspectionsItems(inspection: inspection)
                        }
                    }
                }
            }
        }.addSearchBar(searchBar)
    }
    
    var body: some View {
        Group {
            if sessionStore.inspections.isEmpty, localInspections.isEmpty, sessionStore.inspectionsLoadingState == .failure {
                Text("Нет подключения к интернету!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            } else if sessionStore.inspections.isEmpty, localInspections.isEmpty, sessionStore.inspectionsLoadingState == .success {
                Text("Нет осмотров")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                Text("Добавьте свой первый осмотр и он отобразиться здесь.")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            } else if sessionStore.inspections.isEmpty, localInspections.isEmpty, sessionStore.inspectionsLoadingState == .loading {
                ProgressView("Загрузка")
            } else {
                #if os(watchOS)
                listInspections
                #else
                listInspections
                    .listStyle(InsetGroupedListStyle())
                #endif
            }
        }
        .onAppear(perform: sessionStore.getInspections)
        .navigationTitle("Осмотры")
        .toolbar {
            #if !os(watchOS)
            ToolbarItem(placement: .primaryAction) {
                NavigationLink(destination: CreateInspections()) {
                    Image(systemName: "plus.circle.fill")
                        .imageScale(.large)
                }
            }
            #endif
        }
    }
}
