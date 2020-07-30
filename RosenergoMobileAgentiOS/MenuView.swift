//
//  MenuView.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 10.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct MenuView: View {
    
    @AppStorage("countColumns") private var countColumns: Int = 1
    @AppStorage("imageButton") private var imageButton: String = "square.grid.2x2"
    
    func changeMenu() {
        if countColumns == 2 {
            countColumns = 1
            imageButton = "square.grid.2x2"
        } else {
            countColumns = 2
            imageButton = "rectangle.grid.1x2"
        }
    }
    
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
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gear")
                                .imageScale(.large)
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: changeMenu) {
                            Image(systemName: imageButton)
                                .imageScale(.large)
                        }
                    }
                }
            #endif
        }
    }
    
    var menu: some View {
        VStack {
            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: countColumns)) {
                #if !os(watchOS)
                NavigationLink(destination: CreateInspections()) {
                    MenuButton(title: "Новый\nосмотр", image: "car", color: .rosenergo)
                }.buttonStyle(PlainButtonStyle())
                #endif
                
                NavigationLink(destination: ListInspections()) {
                    MenuButton(title: "Осмотры", image: "archivebox", color: .red)
                }.buttonStyle(PlainButtonStyle())
                
                #if !os(watchOS)
                NavigationLink(destination: CreateVyplatnyeDela()) {
                    MenuButton(title: "Новое\nвыплатное дело", image: "doc.badge.plus", color: .purple)
                }.buttonStyle(PlainButtonStyle())
                #endif
                
                NavigationLink(destination: ListVyplatnyedela()) {
                    MenuButton(title: "Выплатные\nдела", image: "doc.on.doc", color: .yellow)
                }.buttonStyle(PlainButtonStyle())
                
                #if os(watchOS)
                NavigationLink(destination: SettingsView()) {
                    MenuButton(title: "Настройки", image: "gear", color: .secondary)
                }.buttonStyle(PlainButtonStyle())
                #endif
            }
            .animation(.interactiveSpring())
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
