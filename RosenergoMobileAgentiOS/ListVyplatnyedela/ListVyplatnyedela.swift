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
    
    private func getVyplatnyedela() {
        sessionStore.load(sessionStore.serverURL + "v2/vyplatnyedelas") { [self] (response: Result<PaginationVyplatnyedela, Error>) in
            switch response {
            case let .success(value):
                if value.data.isEmpty {
                    sessionStore.vyplatnyedelaLoadingState = .empty
                } else {
                    sessionStore.vyplatnyedela = value
                    sessionStore.vyplatnyedelaLoadingState = .success
                }
            case let .failure(error):
                sessionStore.vyplatnyedelaLoadingState = .failure(error)
                debugPrint(error)
            }
        }
    }
    
    func loadPage() {
        if let path = sessionStore.vyplatnyedela?.nextPageUrl {
            sessionStore.load(path) { [self] (response: Result<PaginationVyplatnyedela, Error>) in
                switch response {
                case let .success(value):
                    sessionStore.vyplatnyedela!.nextPageUrl = value.nextPageUrl
                    if value.nextPageUrl == nil {
                        load = false
                    }
                    sessionStore.vyplatnyedela!.data.append(contentsOf: value.data)
                case let .failure(error):
                    sessionStore.vyplatnyedelaLoadingState = .failure(error)
                    debugPrint(error)
                }
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
        .onAppear(perform: getVyplatnyedela)
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
