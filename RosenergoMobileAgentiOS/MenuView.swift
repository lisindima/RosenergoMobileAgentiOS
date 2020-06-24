//
//  MenuView.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 10.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct MenuView: View {
    
    @EnvironmentObject var sessionStore: SessionStore
    
    private var appVersionView: Text {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return Text("Версия: \(version) (\(build))")
        } else {
            return Text("#chad")
        }
    }
    
    let layout = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                LazyVGrid(columns: layout) {
                    NavigationLink(destination: CreateInspections(), isActive: $sessionStore.openCreateInspections) {
                        MenuButton(title: "Новый\nосмотр", image: "car", color: .rosenergo)
                    }
                    NavigationLink(destination: ListInspections(), isActive: $sessionStore.openListInspections) {
                        MenuButton(title: "Осмотры", image: "list.bullet.below.rectangle", color: .red)
                    }
                    NavigationLink(destination: CreateVyplatnyeDela(), isActive: $sessionStore.openCreateVyplatnyeDela) {
                        MenuButton(title: "Выплатные\nдела", image: "tray", color: .purple)
                    }
                }
                .padding(.top, 8)
                .padding(.horizontal)
                Spacer()
                appVersionView
                    .foregroundColor(.secondary)
                    .font(.system(size: 11))
                    .padding(.bottom, 8)
            }
            .navigationBarTitle("Мобильный агент", displayMode: .large)
            .navigationBarItems(trailing: NavigationLink(destination: SettingsView()) {
                Image(systemName: "gear")
                    .imageScale(.large)
            })
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
