//
//  ImageDetail.swift
//  RosenergoMobileAgentwatchOS Extension
//
//  Created by Дмитрий Лисин on 16.06.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import Espera
import SwiftUI
import URLImage

struct ImageDetail: View {
    @State private var currentPosition: CGSize = .zero
    @State private var newPosition: CGSize = .zero
    @State private var scale: CGFloat = 1.0
    
    var photo: String
    
    var body: some View {
        URLImage(URL(string: photo)!, placeholder: { _ in
            LoadingFlowerView()
                .frame(width: 24, height: 24)
        }) { proxy in
            proxy.image
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
        .scaleEffect(scale)
        .focusable(true)
        .digitalCrownRotation($scale, from: 1.0, through: 5.0, by: 0.1, sensitivity: .low, isContinuous: false, isHapticFeedbackEnabled: true)
        .offset(x: currentPosition.width, y: currentPosition.height)
        .gesture(
            DragGesture()
                .onChanged { value in
                    if scale != 1.0 {
                        currentPosition = CGSize(width: value.translation.width + newPosition.width, height: value.translation.height + newPosition.height)
                    } else {
                        currentPosition = .zero
                    }
                }
                .onEnded { value in
                    if scale != 1.0 {
                        currentPosition = CGSize(width: value.translation.width + newPosition.width, height: value.translation.height + newPosition.height)
                        newPosition = currentPosition
                    } else {
                        currentPosition = .zero
                    }
                }
        )
        .animation(.interactiveSpring())
        .navigationBarTitle("Фотография")
    }
}
