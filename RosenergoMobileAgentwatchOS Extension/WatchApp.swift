//
//  WatchApp.swift
//  RosenergoMobileAgentwatchOS Extension
//
//  Created by Дмитрий Лисин on 25.06.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

@main
struct WatchApp: App {
    
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var sessionStore = SessionStore()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                RootView()
                    .environmentObject(sessionStore)
            }
        }.onChange(of: scenePhase) { newScenePhase in
            if newScenePhase == .active {
                if SessionStore.shared.loginModel != nil {
                    print("HF,JNFTN")
                    SessionStore.shared.validateToken()
                }
            }
        }
    }
}
