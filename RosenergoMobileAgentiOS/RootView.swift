//
//  RootView.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 10.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import CoreLocation
import SwiftUI

struct RootView: View {
    @EnvironmentObject private var sessionStore: SessionStore
    
    #if !os(watchOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @EnvironmentObject private var locationStore: LocationStore
    @StateObject var notificationStore = NotificationStore.shared
    @State private var manager = CLLocationManager()
    #endif
    
    var body: some View {
        if sessionStore.loginModel != nil {
            #if os(iOS)
            if horizontalSizeClass == .compact {
                MenuView()
                    .onAppear { manager.delegate = locationStore }
                    .environmentObject(notificationStore)
            } else {
                SideBar()
                    .onAppear { manager.delegate = locationStore }
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
