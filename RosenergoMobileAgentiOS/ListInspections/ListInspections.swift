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
    #if !os(watchOS)
    @EnvironmentObject private var notificationStore: NotificationStore
    #endif
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \LocalInspections.dateInspections, ascending: true)],
        animation: .default
    )
    private var localInspections: FetchedResults<LocalInspections>
    
    @State private var load: Bool = true
    @State private var searchInspections = [Inspections]()
    
    private func delete(offsets: IndexSet) {
        for offset in offsets {
            let localInspection = localInspections[offset]
            moc.delete(localInspection)
            #if !os(watchOS)
            notificationStore.cancelNotifications(localInspection.id.uuidString)
            #endif
        }
        do {
            try moc.save()
        } catch {
            log(error.localizedDescription)
        }
    }
    
    private func searchRequest(_ query: String) {
        sessionStore.load("https://rosenergo.calcn1.ru/api/v2/search/\(query)") { [self] (response: Result<[Inspections], Error>) in
            switch response {
            case let .success(value):
                searchInspections = value
            case let .failure(error):
                log(error.localizedDescription)
            }
        }
    }
    
    func loadPage() {
        sessionStore.loadPageInspe { result in
            switch result {
            case .success(let bool):
                load = bool
            case .failure:
                print("EGC")
            }
        }
    }
    
    var body: some View {
        LoadingView(sessionStore.inspectionsLoadingState, title: "Нет осмотров", subTitle: "Добавьте свой первый осмотр и он отобразиться здесь.") {
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
                    ForEach(searchBar.text.isEmpty ? sessionStore.inspections!.data : searchInspections, id: \.id) { inspection in
                        NavigationLink(destination: InspectionsDetails(inspection: inspection)) {
                            InspectionsItems(inspection: inspection)
                        }
                    }
                    if load, searchBar.text.isEmpty {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        .onAppear(perform: loadPage)
                    }
                }
            }
            .addSearchBar(searchBar)
            .modifier(ListStyle())
        }
        .onChange(of: searchBar.text) { query in
            searchRequest(query)
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
