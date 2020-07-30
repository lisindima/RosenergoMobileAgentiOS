//
//  RosenergoApp.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 26.06.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

@main
struct RosenergoApp: App {
    
    @StateObject var sessionStore = SessionStore.shared
    @StateObject var locationStore = LocationStore.shared
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .accentColor(.rosenergo)
                .environmentObject(sessionStore)
                .environmentObject(locationStore)
        }
        .commands {
            CommandMenu("Команды") {
                Button(action: {}) {
                    Text("Осмотры")
                }
                Button(action: {}) {
                    Text("Выплатные дела")
                }
            }
        }
    }
}
