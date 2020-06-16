//
//  ImageDetail.swift
//  RosenergoMobileAgentwatchOS Extension
//
//  Created by Дмитрий Лисин on 16.06.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

struct ImageDetail: View {
    
    @State private var scale: CGFloat = 1.0
    
    var photo: String
    
    var body: some View {
        WebImage(url: URL(string: photo))
            .resizable()
            .aspectRatio(contentMode: .fit)
            .scaleEffect(scale)
            .focusable(true)
            .digitalCrownRotation($scale, from: 1, through: 5, by: 0.1, sensitivity: .low, isContinuous: false, isHapticFeedbackEnabled: true)
    }
}
