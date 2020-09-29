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
    @StateObject private var sessionStore = SessionStore.shared
    @StateObject private var locationStore = LocationStore.shared
    @StateObject private var notificationStore = NotificationStore.shared
    
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var showfullScreenCover: Bool = false
    @State private var inspectionID: String = ""
    @State private var vyplatnyedelaID: String = ""
    
    let persistenceController = PersistenceController.shared
    
    func open(_ url: URL) {
        inspectionID = ""
        vyplatnyedelaID = ""
        inspectionID = url["inspection"]
        vyplatnyedelaID = url["delo"]
        if !inspectionID.isEmpty || !vyplatnyedelaID.isEmpty {
            showfullScreenCover = true
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
                .fullScreenCover(isPresented: $showfullScreenCover) {
                    NavigationView {
                        if !inspectionID.isEmpty {
                            InspectionLink(inspectionID: $inspectionID)
                                .environmentObject(sessionStore)
                        } else if !vyplatnyedelaID.isEmpty {
                            VyplatnyedelaLink(vyplatnyedelaID: $vyplatnyedelaID)
                                .environmentObject(sessionStore)
                        }
                    }
                }
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                #if os(iOS)
                UIApplication.shared.applicationIconBadgeNumber = 0
                #endif
                NotificationStore.shared.requestPermission()
                NotificationStore.shared.refreshNotificationStatus()
            }
        }
    }
}

extension URL {
    subscript(queryParam: String) -> String {
        guard let url = URLComponents(string: absoluteString) else { return "" }
        return url.queryItems?.first(where: { $0.name == queryParam })?.value ?? ""
    }
}
