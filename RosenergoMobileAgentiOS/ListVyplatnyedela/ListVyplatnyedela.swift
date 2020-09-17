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
    @State private var load: Bool = true
    
    func loadPage() {
        sessionStore.loadPageVyplat { result in
            switch result {
            case .success(let bool):
                load = bool
            case .failure:
                print("")
            }
        }
    }
    
    var body: some View {
        LoadingView(sessionStore.vyplatnyedelaLoadingState, title: "Нет выплатных дел", subTitle: "Добавьте своё первое выплатное дело и оно отобразиться здесь.") {
            List {
                Section(header: Text("Отправленные дела").fontWeight(.bold)) {
                    ForEach(sessionStore.vyplatnyedela!.data, id: \.id) { vyplatnyedela in
                        NavigationLink(destination: VyplatnyedelaDetails(vyplatnyedela: vyplatnyedela)) {
                            VyplatnyedelaItems(vyplatnyedela: vyplatnyedela)
                        }
                    }
                    if load {
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
