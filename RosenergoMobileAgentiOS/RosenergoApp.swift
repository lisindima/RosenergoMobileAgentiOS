//
//  RosenergoApp.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 26.06.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

@main
struct WatchApp: App {
    
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject var sessionStore = SessionStore()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                RootView()
                    .environmentObject(sessionStore)
            }
        }
        .onChange(of: scenePhase) { newScenePhase in
            switch newScenePhase {
            case .active:
                if SessionStore.shared.loginModel != nil {
                    SessionStore.shared.validateToken()
                }
            case .inactive:
                print("scene is now inactive!")
            case .background:
                print("scene is now in the background!")
            @unknown default:
                print("Apple must have added something new!")
            }
        }
    }
}
