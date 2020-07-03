//
//  LocalImageDetail.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 26.06.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct LocalImageDetail: View {
    
    #if os(watchOS)
    @State private var currentPosition: CGSize = .zero
    @State private var newPosition: CGSize = .zero
    @State private var scale: CGFloat = 1.0
    #else
    @State private var currentAmount: CGFloat = 0
    @State private var finalAmount: CGFloat = 1
    #endif
    
    var photo: String
    
    @ViewBuilder var body: some View {
        #if !os(watchOS)
        localImageDetail
            .scaleEffect(finalAmount + currentAmount)
            .gesture(
                MagnificationGesture()
                    .onChanged { amount in
                        self.currentAmount = amount - 1
                    }
                    .onEnded { amount in
                        self.finalAmount += self.currentAmount
                        self.currentAmount = 0
                    }
            )
            .navigationBarTitle("Фотография", displayMode: .inline)
        #else
        localImageDetail
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
            .onChange(of: scale) { newValue in
                if newValue == 1.0 {
                    currentPosition = .zero
                    newPosition = .zero
                }
            }
            .animation(.interactiveSpring())
            .navigationBarTitle("Фотография")
        #endif
    }
    
    var localImageDetail: some View {
        Image(uiImage: UIImage(data: Data(base64Encoded: photo, options: .ignoreUnknownCharacters)!)!)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}