//
//  ListVyplatnyedela.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 30.07.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import NativeSearchBar
import SwiftUI

struct ListVyplatnyedela: View {
    @EnvironmentObject private var sessionStore: SessionStore
    
    @StateObject private var searchBar = SearchBar.shared
    
    var body: some View {
        #if os(watchOS)
        vyplatnyedela
        #else
        vyplatnyedela
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink(destination: CreateVyplatnyeDela()) {
                        Image(systemName: "plus.circle.fill")
                            .imageScale(.large)
                    }
                }
            }
        #endif
    }
    
    var vyplatnyedela: some View {
        LoadingView(sessionStore.vyplatnyedelaLoadingState, title: "Нет выплатных дел", subTitle: "Добавьте своё первое выплатное дело и оно отобразиться здесь.") { vyplatnyedelaModel in
            List {
                Section(header: Text("Отправленные дела").fontWeight(.bold)) {
                    ForEach(vyplatnyedelaModel.filter {
                        searchBar.text.isEmpty || $0.numberZayavlenia.localizedStandardContains(searchBar.text)
                    }, id: \.id) { vyplatnyedela in
                        NavigationLink(destination: VyplatnyedelaDetails(vyplatnyedela: vyplatnyedela)) {
                            VyplatnyedelaItems(vyplatnyedela: vyplatnyedela)
                        }
                    }
                }
            }
            .addSearchBar(searchBar)
            .modifier(ListStyle())
        }
        .onAppear(perform: sessionStore.getVyplatnyedela)
        .navigationTitle("Выплатные дела")
    }
}
