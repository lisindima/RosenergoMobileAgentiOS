//
//  RosenergoApp.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 26.06.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import Firebase
import SwiftUI

@main
struct RosenergoApp: App {
    @StateObject private var sessionStore = SessionStore.shared
    @StateObject private var locationStore = LocationStore.shared
    @StateObject private var notificationStore = NotificationStore.shared
    
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var urlType: URLType?
    
    let persistenceController = PersistenceController.shared
    
    init() {
        FirebaseApp.configure()
        Crashlytics.crashlytics().setUserID(SessionStore.shared.loginModel?.email ?? "")
    }
    
    func open(_ url: URL) {
        if !url["inspection"].isEmpty {
            urlType = .inspection(url["inspection"])
        } else if !url["delo"].isEmpty {
            urlType = .vyplatnyedela(url["delo"])
        }
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .accentColor(.rosenergo)
                .environmentObject(sessionStore)
                .environmentObject(locationStore)
                .environmentObject(notificationStore)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onOpenURL { url in
                    open(url)
                }
                .onContinueUserActivity("com.rosenergomobileagent.inspectionsdetails") { userActivity in
                    if let url = userActivity.userInfo?["url"] as? URL {
                        open(url)
                    }
                }
                .fullScreenCover(item: $urlType) { urlType in
                    NavigationView {
                        switch urlType {
                        case let .inspection(id):
                            InspectionLink(inspectionID: id)
                                .environmentObject(sessionStore)
                        case let .vyplatnyedela(id):
                            VyplatnyedelaLink(vyplatnyedelaID: id)
                                .environmentObject(sessionStore)
                        }
                    }
                }
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                NotificationStore.shared.requestPermission()
                NotificationStore.shared.refreshNotificationStatus()
            }
        }
    }
}
