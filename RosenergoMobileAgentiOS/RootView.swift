//
//  RootView.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 10.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct RootView: View {
    
    @EnvironmentObject var sessionStore: SessionStore
    @Environment(\.scenePhase) private var scenePhase
    
    #if !os(watchOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif
    
    var body: some View {
        Group {
            if sessionStore.loginModel != nil {
                #if os(iOS)
                if horizontalSizeClass == .compact {
                    MenuView()
                } else {
                    SideBar()
                }
                #else
                MenuView()
                #endif
            } else {
                SignIn()
            }
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
                //coreData.saveContext()
            } else {
                print("Apple must have added something new!")
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
