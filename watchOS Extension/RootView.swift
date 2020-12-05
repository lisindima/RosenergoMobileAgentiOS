//
//  RootView.swift
//  RosenergoMobileAgent (watchOS Extension)
//
//  Created by Дмитрий Лисин on 29.09.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var sessionStore: SessionStore
    
    var body: some View {
        if sessionStore.loginModel != nil {
            NavigationView {
                MenuView()
            }
        } else {
            SignIn()
        }
    }
}
