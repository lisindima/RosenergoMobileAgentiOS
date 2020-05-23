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
    
    @State private var showSettings: Bool = false
    
    private var appVersionView: some View {
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
                HStack {
                    NavigationLink(destination: CreateInspections()) {
                        MenuButton(title: "Новый осмотр", image: "car", color: .rosenergo)
                    }.padding(.trailing, 4)
                    NavigationLink(destination: ListInspections()) {
                        MenuButton(title: "Осмотры", image: "list.bullet.below.rectangle", color: .red)
                    }.padding(.leading, 4)
                }
                .padding(.top, 8)
                .padding(.horizontal)
                HStack {
                    NavigationLink(destination: CreateVyplatnyeDela()) {
                        MenuButton(title: "Выплатные дела", image: "tray", color: .purple)
                    }
                }
                .padding(.top, 8)
                .padding(.horizontal)
                Spacer()
                appVersionView
                    .foregroundColor(.secondary)
                    .font(.system(size: 12))
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .environmentObject(self.sessionStore)
            }
            .navigationBarTitle("Мобильный агент")
            .navigationBarItems(trailing: Button(action: {
                    self.showSettings = true
                }) {
                    Image(systemName: "gear")
                        .imageScale(.large)
            })
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
