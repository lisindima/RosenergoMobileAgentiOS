//
//  ImageDetail.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 24.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import URLImage

struct ImageDetail: View {
    
    #if os(watchOS)
    @State private var currentPosition: CGSize = .zero
    @State private var newPosition: CGSize = .zero
    @State private var scale: CGFloat = 1.0
    #else
    @State private var currentAmount: CGFloat = 0
    @State private var finalAmount: CGFloat = 1
    #endif
    
    @Binding var selection: Int
    var photos: [Photo]
    
    @ViewBuilder var body: some View {
        #if os(watchOS)
        watch
        #else
        phone
        #endif
    }
    
    #if os(watchOS)
    var watch: some View {
        TabView() {
            ForEach(photos, id: \.id) { photo in
                URLImage(URL(string: photo.path)!, placeholder: { _ in
                    ProgressView()
                }, content: {
                    $0.image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                })
                .scaleEffect(scale)
                .focusable(true)
                .digitalCrownRotation($scale, from: 1.0, through: 5.0, by: 0.1, sensitivity: .low, isContinuous: false, isHapticFeedbackEnabled: true)
                .offset(x: currentPosition.width, y: currentPosition.height)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if scale != 1.0 {
                                currentPosition = CGSize(width: value.translation.width + newPosition.width, height: value.translation.height + newPosition.height)
                            }
                        }
                        .onEnded { value in
                            if scale != 1.0 {
                                currentPosition = CGSize(width: value.translation.width + newPosition.width, height: value.translation.height + newPosition.height)
                                newPosition = currentPosition
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
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .navigationTitle("Фотография")
    }
    #endif
    
    #if os(iOS)
    var phone: some View {
        TabView(selection: $selection) {
            ForEach(photos, id: \.id) { photo in
                URLImage(URL(string: photo.path)!, placeholder: { _ in
                    ProgressView()
                }, content: {
                    $0.image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                })
                .tag(photo.id)
                .scaleEffect(finalAmount + currentAmount)
                .gesture(
                    MagnificationGesture()
                        .onChanged { amount in
                            currentAmount = amount - 1
                        }
                        .onEnded { amount in
                            finalAmount += currentAmount
                            currentAmount = 0
                        }
                )
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .navigationTitle("\(selection) из \(photos.count)")
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
    }
    #endif
}
