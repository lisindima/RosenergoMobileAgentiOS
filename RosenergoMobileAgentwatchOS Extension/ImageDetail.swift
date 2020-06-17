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
    
    @State private var currentPosition: CGSize = .zero
    @State private var newPosition: CGSize = .zero
    @State private var scale: CGFloat = 1.0
    
    var photo: String
    
    var body: some View {
        WebImage(url: URL(string: photo))
            .resizable()
            .aspectRatio(contentMode: .fit)
            .scaleEffect(scale)
            .focusable(true)
            .digitalCrownRotation($scale, from: 1.0, through: 5.0, by: 0.1, sensitivity: .low, isContinuous: false, isHapticFeedbackEnabled: true)
            .offset(x: self.currentPosition.width, y: self.currentPosition.height)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if self.scale != 1.0 {
                            self.currentPosition = CGSize(width: value.translation.width + self.newPosition.width, height: value.translation.height + self.newPosition.height)
                        }
                    }
                    .onEnded { value in
                        if self.scale != 1.0 {
                            self.currentPosition = CGSize(width: value.translation.width + self.newPosition.width, height: value.translation.height + self.newPosition.height)
                            self.newPosition = self.currentPosition
                        }
                    }
            )
    }
}
