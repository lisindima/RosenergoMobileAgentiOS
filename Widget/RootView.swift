//
//  RootView.swift
//  RosenergoMobileAgent (Widget)
//
//  Created by Дмитрий Лисин on 29.09.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import WidgetKit
import SwiftUI

@main
struct RootView: WidgetBundle {
    var body: some Widget {
        LocalInspectionsWidget()
        ButtonWidget()
    }
}
