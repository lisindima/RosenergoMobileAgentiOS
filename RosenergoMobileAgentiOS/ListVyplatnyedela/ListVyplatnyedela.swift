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

    var listVyplatnyedela: some View {
        List {
            ForEach(sessionStore.vyplatnyedela.reversed().filter {
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
            if sessionStore.vyplatnyedela.isEmpty, sessionStore.vyplatnyedelaLoadingState == .failure {
                Text("Нет подключения к интернету!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            } else if sessionStore.vyplatnyedela.isEmpty, sessionStore.vyplatnyedelaLoadingState == .success {
                Text("Нет выплатных дел")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                Text("Добавьте своё первое выплатное дело и оно отобразиться здесь.")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            } else if sessionStore.vyplatnyedela.isEmpty, sessionStore.vyplatnyedelaLoadingState == .loading {
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
            #if !os(watchOS)
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink(destination: CreateVyplatnyeDela()) {
                        Image(systemName: "plus.circle.fill")
                            .imageScale(.large)
                    }
                }
            #endif
        }
    }
}
