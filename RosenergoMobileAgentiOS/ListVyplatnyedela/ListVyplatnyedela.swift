//
//  ListVyplatnyedela.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 30.07.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import NativeSearchBar

struct ListVyplatnyedela: View {
    
    @EnvironmentObject private var sessionStore: SessionStore
    
    @StateObject private var searchBar = SearchBar.shared
    @State private var showSortSetting: Bool = false
    
    @AppStorage("sortedByNewVyplatnyedela") private var sortedByNew: Bool = true
    
    var listVyplatnyedela: some View {
        List {
            ForEach(sessionStore.vyplatnyedela.sorted {
                sortedByNew ? $0.id > $1.id : $0.id < $1.id
            }.filter {
                searchBar.text.isEmpty || $0.numberZayavlenia.localizedStandardContains(searchBar.text)
            }, id: \.id) { vyplatnyedela in
                NavigationLink(destination: VyplatnyedelaDetails(vyplatnyedela: vyplatnyedela)) {
                    VyplatnyedelaItems(vyplatnyedela: vyplatnyedela)
                }
            }
        }.addSearchBar(searchBar)
    }
        
    var body: some View {
        Group {
            if sessionStore.vyplatnyedela.isEmpty && sessionStore.vyplatnyedelaLoadingState == .failure {
                Text("Нет подключения к интернету!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            } else if sessionStore.vyplatnyedela.isEmpty && sessionStore.vyplatnyedelaLoadingState == .success {
                Text("Нет выплатных дел")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                Text("Добавьте своё первое выплатное дело и оно отобразиться здесь.")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            } else if sessionStore.vyplatnyedela.isEmpty && sessionStore.vyplatnyedelaLoadingState == .loading {
                ProgressView()
            } else {
                #if os(watchOS)
                listVyplatnyedela
                #else
                listVyplatnyedela
                    .listStyle(InsetGroupedListStyle())
                #endif
            }
        }
        .onAppear(perform: sessionStore.getVyplatnyedela)
        .navigationTitle("Выплатные дела")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack {
                    Button(action: {
                        showSortSetting = true
                    }) {
                        Image(systemName: "line.horizontal.3.decrease.circle")
                            .imageScale(.large)
                    }
                    #if !os(watchOS)
                    NavigationLink(destination: CreateVyplatnyeDela()) {
                        Image(systemName: "plus.circle.fill")
                            .imageScale(.large)
                    }
                    #endif
                }
            }
        }
        .actionSheet(isPresented: $showSortSetting) {
            ActionSheet(title: Text("Сортировка"), message: Text("В каком порядке отображать список выплатных дел?"), buttons: [
                .default(Text("Сначала новые")) {
                    sortedByNew = true
                }, .default(Text("Сначала старые")) {
                    sortedByNew = false
                }, .cancel()
            ])
        }
    }
}
