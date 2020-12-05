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
        NavigationView {
            SideBar()
        }
    }
}

