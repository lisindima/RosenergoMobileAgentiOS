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
    @State private var isOpenUrlId: String?

    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .accentColor(.rosenergo)
                .environmentObject(sessionStore)
                .environmentObject(locationStore)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onOpenURL { url in
                    isOpenUrlId = url["inspection"]
                    if isOpenUrlId != nil {
                        showfullScreenCover = true
                    }
                }
                .alert(isPresented: $sessionStore.showServerAlert) {
                    Alert(title: Text("Нет интернета"), message: Text("Сохраняйте осмотры на устройство."), dismissButton: .default(Text("Закрыть")))
                }
                .fullScreenCover(isPresented: $showfullScreenCover) {
                    LinkDetails(isOpenUrlId: $isOpenUrlId)
                        .environmentObject(sessionStore)
                }
                .onChange(of: scenePhase) { phase in
                    if phase == .active {
                        print("scene is now active!")
                        #if !os(watchOS)
                            UIApplication.shared.applicationIconBadgeNumber = 0
                            NotificationStore.shared.requestPermission()
                            NotificationStore.shared.refreshNotificationStatus()
                        #endif
                        if SessionStore.shared.loginModel != nil {
                            SessionStore.shared.validateToken()
                        }
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
