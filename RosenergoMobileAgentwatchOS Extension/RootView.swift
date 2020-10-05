//
//  RootView.swift
//  RosenergoMobileAgentwatchOS Extension
//
//  Created by Дмитрий Лисин on 15.06.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct RootView: View {
    @ObservedObject var sessionStore = SessionStore.shared
    
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
