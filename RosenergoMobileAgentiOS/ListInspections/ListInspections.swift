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
    
    @State private var isLoading: Bool = false
    
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
                        Section(header: Text("Не отправленные осмотры".uppercased())) {
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
                        Section(header: Text("Отправленные осмотры".uppercased())) {
                            ForEach(sessionStore.inspections.filter {
                                searchBar.text.isEmpty || $0.insuranceContractNumber.localizedStandardContains(searchBar.text)
                            }, id: \.id) { inspection in
                                NavigationLink(destination: InspectionsDetails(inspection: inspection)) {
                                    InspectionsItems(inspection: inspection)
                                }
                            }
                        }
                    }
                }
                .onPull(perform: {
                    self.isLoading = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self.isLoading = false
                    }
                }, isLoading: isLoading)
                .addSearchBar(searchBar)
                .listStyle(GroupedListStyle())
            }
        }
        .onAppear(perform: sessionStore.getInspections)
        .navigationBarTitle("Осмотры")
        .navigationBarItems(trailing:
            NavigationLink(destination: CreateInspections()) {
                Image(systemName: "plus.circle")
                    .imageScale(.large)
            }
        )
    }
}
