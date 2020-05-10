//
//  RootView.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 10.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct RootView: View {
    
    @ObservedObject var sessionStore: SessionStore = SessionStore.shared
    
    var body: some View {
        Group {
            if sessionStore.loginModel != nil {
                MenuView()
            } else {
                SignIn()
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
