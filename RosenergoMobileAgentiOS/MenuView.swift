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
                    NavigationLink(destination: CreateInspections(), isActive: $sessionStore.openCreateInspections) {
                        MenuButton(title: "Новый\nосмотр", image: "car", color: .rosenergo)
                    }.padding(.trailing, 4)
                    NavigationLink(destination: ListInspections()) {
                        MenuButton(title: "Осмотры", image: "list.bullet.below.rectangle", color: .red)
                    }.padding(.leading, 4)
                }
                .padding(.top, 8)
                .padding(.horizontal)
                HStack {
                    NavigationLink(destination: CreateVyplatnyeDela(), isActive: $sessionStore.openCreateVyplatnyeDela) {
                        MenuButton(title: "Выплатные\nдела", image: "tray", color: .purple)
                    }.padding(.trailing, 4)
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.clear)
                        .frame(maxWidth: .infinity, maxHeight: 120)
                        .padding(.leading, 4)
                }
                .padding(.top, 8)
                .padding(.horizontal)
                Spacer()
                appVersionView
                    .foregroundColor(.secondary)
                    .font(.system(size: 11))
                    .padding(.bottom, 8)
            }
            .onAppear(perform: sessionStore.getLocation)
            .navigationBarTitle("Мобильный агент")
            .navigationBarItems(trailing: NavigationLink(destination: SettingsView()) {
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
