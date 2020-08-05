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
    
    #if !os(watchOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @StateObject var notificationStore = NotificationStore.shared
    #endif
    
    var body: some View {
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
}
