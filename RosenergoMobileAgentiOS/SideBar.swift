//
//  SideBar.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 27.06.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct SideBar: View {
    
    enum NavigationItem {
        case createInspections
        case listInspections
        case createVyplatnye
    }

    @State private var selection: Set<NavigationItem> = [.createInspections]
    @State private var openSettings = false
    
    var body: some View {
        NavigationView {
            List(selection: $selection) {
                NavigationLink(destination: CreateInspections()) {
                    Label("Новый осмотр", systemImage: "car")
                }.tag(NavigationItem.createInspections)
                
                NavigationLink(destination: ListInspections()) {
                    Label("Осмотры", systemImage: "pc")
                }.tag(NavigationItem.listInspections)
            
                NavigationLink(destination: CreateVyplatnyeDela()) {
                    Label("Выплатные дела", systemImage: "tray")
                }.tag(NavigationItem.createVyplatnye)
            }
            .overlay(SettingsButtonBar(openSettings: $openSettings), alignment: .bottom)
            .listStyle(SidebarListStyle())
            .navigationTitle("Главная")
        
            Text("Выберите\nпункт в меню")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Text("Выберите осмотр\nдля просмотра")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
