//
//  ListInspections.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 10.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import NativeSearchBar

struct ListInspections: View {
    
    @EnvironmentObject private var sessionStore: SessionStore
    @EnvironmentObject private var notificationStore: NotificationStore
    @Environment(\.managedObjectContext) private var moc
    
    @FetchRequest(entity: LocalInspections.entity(), sortDescriptors: []) var localInspections: FetchedResults<LocalInspections>
    
    @StateObject private var searchBar = SearchBar.shared
    
    @State private var showSortSetting: Bool = false
    @AppStorage("sortedByNew") var sortedByNew: Bool = true
    
    func delete(at offsets: IndexSet) {
        for offset in offsets {
            let localInspection = localInspections[offset]
            moc.delete(localInspection)
            notificationStore.cancelNotifications(id: localInspection.id!.uuidString)
        }
        try? moc.save()
    }
    
    var body: some View {
        Group {
            if sessionStore.inspections.isEmpty && localInspections.isEmpty && sessionStore.inspectionsLoadingState == .failure {
                Text("Нет подключения к интернету!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            } else if sessionStore.inspections.isEmpty && localInspections.isEmpty && sessionStore.inspectionsLoadingState == .success {
                Text("Нет осмотров")
                    .font(.title)
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
                    if !localInspections.isEmpty {
                        Section(header: Text("Не отправленные осмотры").fontWeight(.bold)) {
                            ForEach(localInspections.filter {
                                searchBar.text.isEmpty || $0.insuranceContractNumber!.localizedStandardContains(searchBar.text)
                            }, id: \.id) { localInspections in
                                NavigationLink(destination: LocalInspectionsDetails(localInspections: localInspections)) {
                                    LocalInspectionsItems(localInspections: localInspections)
                                }
                            }.onDelete(perform: delete)
                        }
                    }
                    if !sessionStore.inspections.isEmpty {
                        Section(header: Text("Отправленные осмотры").fontWeight(.bold)) {
                            ForEach(sessionStore.inspections.sorted {
                                sortedByNew ? $0.id > $1.id : $0.id < $1.id
                            }.filter {
                                searchBar.text.isEmpty || $0.insuranceContractNumber.localizedStandardContains(searchBar.text)
                            }, id: \.id) { inspection in
                                NavigationLink(destination: InspectionsDetails(inspection: inspection)) {
                                    InspectionsItems(inspection: inspection)
                                }
                            }
                        }
                    }
                }
                .addSearchBar(searchBar)
                .listStyle(InsetGroupedListStyle())
            }
        }
        .onAppear(perform: sessionStore.getInspections)
        .navigationTitle("Осмотры")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack {
                    Button(action: {
                        showSortSetting = true
                    }) {
                        Image(systemName: "line.horizontal.3.decrease.circle")
                            .imageScale(.large)
                    }
                    NavigationLink(destination: CreateInspections()) {
                        Image(systemName: "plus.circle.fill")
                            .imageScale(.large)
                    }
                }
            }
        }
        .actionSheet(isPresented: $showSortSetting) {
            ActionSheet(title: Text("Сортировка"), message: Text("В каком порядке отображать список осмотров?"), buttons: [
                .default(Text("Сначала новые")) {
                    sortedByNew = true
                }, .default(Text("Сначала старые")) {
                    sortedByNew = false
                }, .cancel()
            ])
        }
    }
}
