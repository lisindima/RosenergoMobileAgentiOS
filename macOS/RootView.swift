//
//  RootView.swift
//  RosenergoMobileAgent (macOS)
//
//  Created by Дмитрий Лисин on 05.12.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var sessionStore: SessionStore
    
    var body: some View {
        if sessionStore.loginModel != nil {
            NavigationView {
                SideBar()
                    .navigationTitle("Мобильный агент")
            }
            .frame(minWidth: 500, idealWidth: 600, maxWidth: nil, minHeight: 300, idealHeight: 400, maxHeight: nil)
        } else {
            SignIn()
        }
    }
}
