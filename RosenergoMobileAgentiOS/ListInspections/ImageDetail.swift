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
    
    @State private var currentPosition: CGSize = .zero
    @State private var newPosition: CGSize = .zero
    @State private var currentAmount: CGFloat = 0
    @State private var finalAmount: CGFloat = 1
    
    var photo: String
    
    var body: some View {
        VStack {
            URLImage(URL(string: photo)!, placeholder: { _ in
                ActivityIndicator(styleSpinner: .medium)
            }) { proxy in
                proxy.image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }.navigationBarTitle("Фотография", displayMode: .inline)
    }
}

struct LocalImageDetail: View {
    
    @State private var currentPosition: CGSize = .zero
    @State private var newPosition: CGSize = .zero
    @State private var currentAmount: CGFloat = 0
    @State private var finalAmount: CGFloat = 1
    
    var photo: String
    
    var body: some View {
        VStack {
            Image(uiImage: UIImage(data: Data(base64Encoded: photo, options: .ignoreUnknownCharacters)!)!)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }.navigationBarTitle("Фотография", displayMode: .inline)
    }
}
