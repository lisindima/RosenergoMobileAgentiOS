//
//  MenuView.swift
//  RosenergoMobileAgentwatchOS Extension
//
//  Created by Дмитрий Лисин on 16.06.2020.
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
        VStack {
            NavigationLink(destination: ListInspections()) {
                MenuButton(title: "Осмотры", image: "list.bullet.below.rectangle", color: .purple)
            }.buttonStyle(PlainButtonStyle())
            NavigationLink(destination: SettingsView()) {
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
