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
    
    @StateObject var sessionStore = SessionStore.shared
    @StateObject var locationStore = LocationStore.shared
    @StateObject var coreData = CoreData.shared
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .accentColor(.rosenergo)
                .environmentObject(sessionStore)
                .environmentObject(locationStore)
                .environment(\.managedObjectContext, coreData.persistentContainer.viewContext)
        }
    }
}
