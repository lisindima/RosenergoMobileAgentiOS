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
    #if !os(watchOS)
        @EnvironmentObject private var notificationStore: NotificationStore
    #endif

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 1), spacing: 8) {
                    #if !os(watchOS)
                        NavigationLink(destination: CreateInspections()) {
                            MenuButton(title: "Новый\nосмотр", image: "car", color: .rosenergo)
                        }
                        .buttonStyle(PlainButtonStyle())
                    #endif

                    NavigationLink(destination: ListInspections()) {
                        MenuButton(title: "Осмотры", image: "archivebox", color: .red)
                    }
                    .buttonStyle(PlainButtonStyle())

                    #if !os(watchOS)
                        NavigationLink(destination: CreateVyplatnyeDela()) {
                            MenuButton(title: "Новое\nвыплатное дело", image: "doc.badge.plus", color: .purple)
                        }
                        .buttonStyle(PlainButtonStyle())
                    #endif

                    NavigationLink(destination: ListVyplatnyedela()) {
                        MenuButton(title: "Выплатные\nдела", image: "doc.on.doc", color: .yellow)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.top, 8)
                .padding(.horizontal)
            }
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
}
