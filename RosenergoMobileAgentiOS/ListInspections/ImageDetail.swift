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
    
    @State private var currentAmount: CGFloat = 0
    @State private var finalAmount: CGFloat = 1
    
    var photo: String
    
    var body: some View {
        VStack {
            URLImage(URL(string: photo)!, placeholder: { _ in
                ProgressView()
            }) { proxy in
                proxy.image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
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
        }.navigationBarTitle("Фотография", displayMode: .inline)
    }
}

struct LocalImageDetail: View {
    
    @State private var currentAmount: CGFloat = 0
    @State private var finalAmount: CGFloat = 1
    
    var photo: String
    
    var body: some View {
        VStack {
            Image(uiImage: UIImage(data: Data(base64Encoded: photo, options: .ignoreUnknownCharacters)!)!)
                .resizable()
                .aspectRatio(contentMode: .fit)
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
        }.navigationBarTitle("Фотография", displayMode: .inline)
    }
}
