//
//  MenuView.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 10.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct MenuView: View {
    @EnvironmentObject private var sessionStore: SessionStore
    @EnvironmentObject private var notificationStore: NotificationStore
    
    @State private var openSettings: Bool = false
    
    var countColumns: Int {
        #if os(watchOS)
        return 1
        #else
        return 2
        #endif
    }
    
    var body: some View {
        #if os(watchOS)
        ScrollView {
            menu
        }
        #else
        VStack {
            menu
                .padding(.horizontal)
            Spacer()
        }
        #endif
    }
    
    var menu: some View {
        LazyVGrid(columns: Array(repeating: .init(.flexible()), count: countColumns), spacing: 8) {
            #if os(iOS)
            MenuButton(title: "Новый\nосмотр", image: "car", color: .rosenergo, destination: CreateInspections())
            #endif
            
            MenuButton(title: "Осмотры", image: "archivebox", color: .red, destination: ListInspections())
            
            #if os(iOS)
            MenuButton(title: "Новое\nвыплатное дело", image: "doc.badge.plus", color: .purple, destination: CreateVyplatnyeDela())
            #endif
            
            MenuButton(title: "Выплатные\nдела", image: "doc.on.doc", color: .yellow, destination: ListVyplatnyedela())
        }
        .padding(.top, 8)
        .navigationTitle("Мобильный агент")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gear")
                        .imageScale(.large)
                }
            }
        }
    }
}
