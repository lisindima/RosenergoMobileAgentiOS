//
//  SettingsButtonBar.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 27.06.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct SettingsButtonBar: View {
    
    @EnvironmentObject private var sessionStore: SessionStore
    
    @Binding var openSettings: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Divider()
            Button(action: { openSettings = true }) {
                Label("Настройки", systemImage: "gear")
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .buttonStyle(PlainButtonStyle())
        }
        .sheet(isPresented: $openSettings) {
            NavigationView {
                SettingsView()
                    .environmentObject(sessionStore)
                    .navigationBarTitle("Настройки", displayMode: .inline)
                    .navigationBarItems(trailing:
                                            Button(action: { openSettings = false }) {
                                                Text("Готово")
                                            }
                    )
            }
        }
    }
}