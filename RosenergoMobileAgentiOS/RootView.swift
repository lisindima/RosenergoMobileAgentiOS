//
//  RootView.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 10.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct RootView: View {
    
    #if os(watchOS)
    @ObservedObject var sessionStore: SessionStore = SessionStore.shared
    #else
    @EnvironmentObject var sessionStore: SessionStore
    #endif
    
    @ViewBuilder var body: some View {
        if sessionStore.loginModel != nil {
            MenuView()
        } else {
            SignIn()
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
