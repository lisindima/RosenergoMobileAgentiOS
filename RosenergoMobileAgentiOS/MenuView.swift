//
//  MenuView.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 10.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct MenuView: View {
    
    private var appVersionView: Text {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return Text("Версия: \(version) (\(build))")
        } else {
            return Text("#chad")
        }
    }
    
    var body: some View {
        NavigationView {
            #if os(watchOS)
            ScrollView {
                menu
            }
            #else
            menu
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gear")
                                .imageScale(.large)
                        }
                    }
                }
            #endif
        }
    }
    
    var menu: some View {
        VStack {
            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 1)) {
                #if !os(watchOS)
                NavigationLink(destination: CreateInspections()) {
                    MenuButton(title: "Новый\nосмотр", image: "car", color: .rosenergo)
                }.buttonStyle(PlainButtonStyle())
                NavigationLink(destination: CreateVyplatnyeDela()) {
                    MenuButton(title: "Новое\nвыплатное дело", image: "doc.badge.plus", color: .purple)
                }.buttonStyle(PlainButtonStyle())
                #endif
                NavigationLink(destination: ListInspections()) {
                    MenuButton(title: "Осмотры", image: "archivebox", color: .red)
                }.buttonStyle(PlainButtonStyle())
                NavigationLink(destination: ListVyplatnyedela()) {
                    MenuButton(title: "Выплатные\nдела", image: "archivebox", color: .yellow)
                }.buttonStyle(PlainButtonStyle())
                #if os(watchOS)
                NavigationLink(destination: SettingsView()) {
                    MenuButton(title: "Настройки", image: "gear", color: .secondary)
                }.buttonStyle(PlainButtonStyle())
                #endif
            }
            .padding(.top, 8)
            .padding(.horizontal)
            Spacer()
            appVersionView
                .foregroundColor(.secondary)
                .font(.system(size: 11))
                .padding(.bottom, 8)
        }
        .navigationTitle("Мобильный агент")
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
