//
//  ListVyplatnyedela.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 31.07.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import NativeSearchBar

struct ListVyplatnyedela: View {
    
    @EnvironmentObject var sessionStore: SessionStore

    @ObservedObject var searchBar: SearchBar = SearchBar.shared
    
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
                Text("Добавьте своё первое выплатное\nдело и оно отобразиться здесь.")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            } else if sessionStore.vyplatnyedela.isEmpty && sessionStore.vyplatnyedelaLoadingState == .loading {
                ActivityIndicator(styleSpinner: .large)
            } else {
                List {
                    ForEach(sessionStore.vyplatnyedela.reversed().filter {
                        searchBar.text.isEmpty || $0.numberZayavlenia.localizedStandardContains(searchBar.text)
                    }, id: \.id) { vyplatnyedela in
                        NavigationLink(destination: VyplatnyedelaDetails(vyplatnyedela: vyplatnyedela)) {
                            VyplatnyedelaItems(vyplatnyedela: vyplatnyedela)
                        }
                    }
                }.addSearchBar(searchBar)
                .listStyle(GroupedListStyle())
            }
        }
        .onAppear(perform: sessionStore.getVyplatnyedela)
        .navigationBarTitle("Выплатные дела")
        .navigationBarItems(trailing:
            NavigationLink(destination: CreateVyplatnyeDela()) {
                Image(systemName: "plus.circle.fill")
                    .imageScale(.large)
            }
        )
    }
}
