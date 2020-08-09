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
    @EnvironmentObject private var notificationStore: NotificationStore
    
    enum NavigationItem {
        case createInspections
        case createVyplatnye
        case listInspections
        case listVyplatnyedela
    }

    @State private var selection: Set<NavigationItem> = [.createInspections]
    @State private var openSettings = false
    
    var body: some View {
        NavigationView {
            List(selection: $selection) {
                #if !targetEnvironment(macCatalyst)
                NavigationLink(destination: CreateInspections()) {
                    Label("Новый осмотр", systemImage: "car")
                }.tag(NavigationItem.createInspections)
                #endif
                NavigationLink(destination: ListInspections()) {
                    Label("Осмотры", systemImage: "archivebox")
                }.tag(NavigationItem.listInspections)
                #if !targetEnvironment(macCatalyst)
                NavigationLink(destination: CreateVyplatnyeDela()) {
                    Label("Новое выплатное дело", systemImage: "doc.badge.plus")
                }.tag(NavigationItem.createVyplatnye)
                #endif
                NavigationLink(destination: ListVyplatnyedela()) {
                    Label("Выплатные дела", systemImage: "doc.on.doc")
                }.tag(NavigationItem.listVyplatnyedela)
            }
            .listStyle(SidebarListStyle())
            .navigationTitle("Главная")
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
                        .environmentObject(sessionStore)
                        .environmentObject(notificationStore)
                        .navigationBarItems(trailing:
                            Button(action: { openSettings = false }) {
                                Text("Закрыть")
                            }
                        )
                }
            }
        
            Text("Выберите\nпункт в меню")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Text("Выберите осмотр\nили выплатное дело\nдля просмотра")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
