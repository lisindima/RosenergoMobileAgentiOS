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
    @StateObject private var coreData = CoreData.shared

    @Environment(\.scenePhase) private var scenePhase

    @State private var showfullScreenCover: Bool = false

    var body: some Scene {
        WindowGroup {
            RootView()
                .accentColor(.rosenergo)
                .environmentObject(sessionStore)
                .environmentObject(locationStore)
                .environment(\.managedObjectContext, coreData.persistentContainer.viewContext)
                .onOpenURL { url in
                    sessionStore.isOpenUrlId = url["inspection"]
                    if sessionStore.isOpenUrlId != nil {
                        showfullScreenCover = true
                    }
                }
                .alert(isPresented: $sessionStore.showServerAlert) {
                    Alert(title: Text("Нет интернета"), message: Text("Сохраняйте осмотры на устройство."), dismissButton: .default(Text("Закрыть")))
                }
                .fullScreenCover(isPresented: $showfullScreenCover) {
                    #if !os(watchOS)
                        LinkDetails()
                    #endif
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
                    } else if phase == .background {
                        print("scene is now background!")
                        coreData.saveContext()
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
