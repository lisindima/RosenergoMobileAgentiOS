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
    @State private var didTapCapture: Bool = false
    @State private var flashOn: Bool = false
    
    var body: some View {
        VStack {
            CustomCameraRepresentable(didTapCapture: $didTapCapture)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(sessionStore.photoParameters, id: \.file) { photo in
                        ZStack {
                            Image(uiImage: UIImage(data: Data.init(base64Encoded: photo.file, options: .ignoreUnknownCharacters)!)!)
                                .renderingMode(.original)
                                .resizable()
                                .frame(width: 100, height: 100)
                                .cornerRadius(10)
                            Button(action: {
                                if let index = self.sessionStore.photoParameters.firstIndex(of: photo) {
                                    self.sessionStore.photoParameters.remove(at: index)
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .imageScale(.large)
                                    .foregroundColor(.red)
                            }.offset(x: 50, y: -50)
                        }
                    }
                }.padding()
            }
            HStack {
                Button(action: {
                    
                }) {
                    Image(systemName: "camera.rotate")
                        .frame(width: 24)
                        .imageScale(.large)
                        .padding(30)
                        .background(Color.rosenergo.opacity(0.2))
                        .foregroundColor(.rosenergo)
                        .clipShape(Circle())
                }.padding(.bottom, 30)
                Button(action: {
                    self.didTapCapture = true
                }) {
                    Image(systemName: "camera")
                        .frame(width: 24)
                        .imageScale(.large)
                        .padding(30)
                        .background(Color.rosenergo)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }.padding(.bottom, 30)
                Button(action: {
                    self.flashOn.toggle()
                }) {
                    Image(systemName: flashOn ? "bolt" : "bolt.slash")
                        .frame(width: 24)
                        .imageScale(.large)
                        .padding(30)
                        .background(Color.rosenergo.opacity(0.2))
                        .foregroundColor(.rosenergo)
                        .clipShape(Circle())
                }.padding(.bottom, 30)
            }
        }
    }
}
