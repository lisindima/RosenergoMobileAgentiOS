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
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @EnvironmentObject private var sessionStore: SessionStore
    @StateObject private var locationStore = LocationStore.shared
    @State private var manager = CLLocationManager()
    
    var body: some View {
        if sessionStore.loginModel != nil {
            NavigationView {
                if horizontalSizeClass == .compact {
                    MenuView()
                } else {
                    SideBar()
                }
            }
            .onAppear { manager.delegate = locationStore }
        } else {
            SignIn()
                .onAppear { manager.delegate = locationStore }
        }
    }
}
