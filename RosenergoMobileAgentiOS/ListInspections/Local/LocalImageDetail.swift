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
    @GestureState var scale: CGFloat = 1.0
    #endif
    
    @State private var selectionImage: Int = 1
    
    var photos: [LocalPhotos]
    
    var body: some View {
        #if os(watchOS)
        watch
        #else
        phone
        #endif
    }
    
    #if os(watchOS)
    var watch: some View {
        TabView(selection: $selectionImage) {
            ForEach(photos, id: \.id) { photo in
                Image(uiImage: UIImage(data: photo.photosData!)!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
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
        TabView(selection: $selectionImage) {
            ForEach(photos, id: \.id) { photo in
                Image(uiImage: UIImage(data: photo.photosData!)!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scale)
                    .gesture(
                        MagnificationGesture()
                            .updating($scale, body: { value, scale, trans in
                                scale = value.magnitude
                            }
                        )
                    )
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .navigationTitle("\(selectionImage) из \(photos.count)")
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
    }
    #endif
}
