//
//  RootView.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 10.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct RootView: View {
    
    @EnvironmentObject private var sessionStore: SessionStore
    @Environment(\.scenePhase) private var scenePhase
    @StateObject var coreData = CoreData.shared
    
    #if !os(watchOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @StateObject var notificationStore = NotificationStore.shared
    #endif
    
    var body: some View {
        Group {
            if sessionStore.loginModel != nil {
                #if os(iOS)
                if horizontalSizeClass == .compact {
                    MenuView()
                        .environmentObject(notificationStore)
                } else {
                    SideBar()
                        .environmentObject(notificationStore)
                }
                #else
                MenuView()
                #endif
            } else {
                SignIn()
            }
        }
        .environment(\.managedObjectContext, coreData.persistentContainer.viewContext)
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                print("scene is now active!")
                #if !os(watchOS)
                UIApplication.shared.applicationIconBadgeNumber = 0
                NotificationStore.shared.requestPermission()
                NotificationStore.shared.refreshNotificationStatus()
                LocationStore.shared.getLocation()
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
