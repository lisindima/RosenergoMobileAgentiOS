//
//  SideBar.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 27.06.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct SideBar: View {
    @EnvironmentObject private var sessionStore: SessionStore
    
    @State private var selection: NavigationItem? = .createInspections
    @State private var openSettings: Bool = false
    
    var sidebar: some View {
        List(selection: $selection) {
            Section(header: Text("Главное")) {
                #if !os(macOS)
                NavigationLink(destination: CreateInspections()) {
                    Label("Новый осмотр", systemImage: "car")
                }
                .tag(NavigationItem.createInspections)
                #endif
                NavigationLink(destination: ListInspections()) {
                    Label("Осмотры", systemImage: "archivebox")
                }
                .tag(NavigationItem.listInspections)
                #if !os(macOS)
                NavigationLink(destination: CreateVyplatnyeDela()) {
                    Label("Новое выплатное дело", systemImage: "doc.badge.plus")
                }
                .tag(NavigationItem.createVyplatnye)
                #endif
                NavigationLink(destination: ListVyplatnyedela()) {
                    Label("Выплатные дела", systemImage: "doc.on.doc")
                }
                .tag(NavigationItem.listVyplatnyedela)
            }
        }
        .listStyle(SidebarListStyle())
        .navigationTitle("Главная")
    }
    
    var body: some View {
        #if os(macOS)
        sidebar
            .frame(width: 180)
        #else
        sidebar
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { openSettings = true }) {
                        Image(systemName: "gear")
                            .imageScale(.large)
                    }
                }
            }
            .sheet(isPresented: $openSettings) {
                NavigationView {
                    SettingsView()
                        .toolbar {
                            ToolbarItem(placement: .primaryAction) {
                                ExitButton(action: { openSettings = false })
                            }
                        }
                }
            }
        #endif
        
        Text("Выберите\nпункт в меню")
            .messageTitle()
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        
        Text("Выберите осмотр\nили выплатное дело\nдля просмотра")
            .messageTitle()
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
