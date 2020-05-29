//
//  CustomCameraView.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 29.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct CustomCameraView: View {
    
    @EnvironmentObject var sessionStore: SessionStore
    @State var didTapCapture: Bool = false
    
    var body: some View {
        VStack {
            CustomCameraRepresentable(didTapCapture: $didTapCapture)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(sessionStore.photoParameters, id: \.file) { photo in
                        Image(uiImage: UIImage(data: Data.init(base64Encoded: photo.file, options: .ignoreUnknownCharacters)!)!)
                            .renderingMode(.original)
                            .resizable()
                            .frame(width: 100, height: 100)
                            .cornerRadius(10)
                    }
                }.padding()
            }
            Button(action: {
                self.didTapCapture = true
            }) {
                Image(systemName: "camera")
                    .imageScale(.large)
                    .padding(30)
                    .background(Color.rosenergo)
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }.padding(.bottom, 30)
        }
    }
}
