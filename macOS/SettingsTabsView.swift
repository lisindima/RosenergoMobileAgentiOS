//
//  SettingsTabsView.swift
//  RosenergoMobileAgent (macOS)
//
//  Created by Дмитрий Лисин on 07.12.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import UserFeedback

struct SettingsTabsView: View {
    private enum Tabs: Hashable {
        case agent, notification, license
    }
    
    var body: some View {
        TabView {
            SettingsView()
                .tabItem { Label("Главное", systemImage: "person") }
                .tag(Tabs.agent)
            NotificationView()
                .tabItem { Label("Уведомления", systemImage: "bell") }
                .tag(Tabs.notification)
            NavigationView {
                License()
            }
            .tabItem { Label("Лицензии", systemImage: "doc.plaintext") }
            .tag(Tabs.notification)
            Text("Обратная связь")
                .tabItem { Label("Обратная связь", systemImage: "ant") }
                .tag(Tabs.notification)
        }
        .padding(20)
        .frame(width: 650, height: 350)
    }
}
