//
//  MenuView.swift
//  RosenergoMobileAgentwatchOS Extension
//
//  Created by Дмитрий Лисин on 16.06.2020.
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
        ScrollView {
            NavigationLink(destination: ListInspections().environmentObject(sessionStore)) {
                MenuButton(title: "Осмотры", image: "pc", color: .rosenergo)
            }.buttonStyle(PlainButtonStyle())
            NavigationLink(destination: SettingsView().environmentObject(sessionStore)) {
                MenuButton(title: "Настройки", image: "gear", color: .secondary)
            }.buttonStyle(PlainButtonStyle())
            appVersionView
                .foregroundColor(.secondary)
                .font(.footnote)
        }.navigationBarTitle("Агент")
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
