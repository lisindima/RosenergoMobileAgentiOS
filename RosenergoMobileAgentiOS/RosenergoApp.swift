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

    @Environment(\.scenePhase) private var scenePhase

    @State private var showfullScreenCover: Bool = false
    @State private var inspectionID: String?

    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .accentColor(.rosenergo)
                .environmentObject(sessionStore)
                .environmentObject(locationStore)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onOpenURL { url in
                    inspectionID = url["inspection"]
                    if inspectionID != nil {
                        showfullScreenCover = true
                    }
                }
                .fullScreenCover(isPresented: $showfullScreenCover) {
                    LinkDetails(inspectionID: $inspectionID)
                        .environmentObject(sessionStore)
                }
                .onChange(of: scenePhase) { phase in
                    if phase == .active {
                        #if !os(watchOS)
                            UIApplication.shared.applicationIconBadgeNumber = 0
                            NotificationStore.shared.requestPermission()
                            NotificationStore.shared.refreshNotificationStatus()
                        #endif
                    }
                }
        }
    }
}

extension URL {
    subscript(queryParam: String) -> String? {
        guard let url = URLComponents(string: absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParam })?.value
    }
}
