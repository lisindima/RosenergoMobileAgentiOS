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
    
    var body: some View {
        NavigationView {
            VStack {
                LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2)) {
                    NavigationLink(destination: CreateInspections()) {
                        MenuButton(title: "Новый\nосмотр", image: "car", color: .rosenergo)
                    }
                    NavigationLink(destination: ListInspections()) {
                        MenuButton(title: "Осмотры", image: "pc", color: .red)
                    }
                    NavigationLink(destination: CreateVyplatnyeDela()) {
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
            .navigationTitle("Мобильный агент")
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
