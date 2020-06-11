//
//  ImageDetail.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 24.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

struct ImageDetail: View {
    
    @GestureState var scale: CGFloat = 1.0
    
    var photo: String
    
    var body: some View {
        VStack {
            WebImage(url: URL(string: photo))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .scaleEffect(scale)
                .gesture(MagnificationGesture()
                    .updating($scale, body: { value, scale, trans in
                        scale = value.magnitude
                    }
                )
            )
        }.navigationBarTitle("Фотография", displayMode: .inline)
    }
}

struct LocalImageDetail: View {
    
    @GestureState var scale: CGFloat = 1.0
    
    var photo: String
    
    var body: some View {
        VStack {
            Image(uiImage: UIImage(data: Data(base64Encoded: photo, options: .ignoreUnknownCharacters)!)!)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .scaleEffect(scale)
                .gesture(MagnificationGesture()
                    .updating($scale, body: { value, scale, trans in
                        scale = value.magnitude
                    }
                )
            )
        }.navigationBarTitle("Фотография", displayMode: .inline)
    }
}
