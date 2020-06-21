//
//  CustomCameraView.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 29.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import AVFoundation

struct CustomCameraView: View {
    
    @EnvironmentObject var sessionStore: SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    @State private var didTapCapture: Bool = false
    @State private var flashMode: AVCaptureDevice.FlashMode = .off
    
    func flashState() {
        if flashMode == .on {
            flashMode = .off
        } else if flashMode == .off {
            flashMode = .on
        }
    }
    
    var body: some View {
        VStack {
            CustomCameraRepresentable(didTapCapture: $didTapCapture, flashMode: $flashMode)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(sessionStore.photoParameters.reversed(), id: \.file) { photo in
                        ZStack {
                            Image(uiImage: UIImage(data: Data(base64Encoded: photo.file, options: .ignoreUnknownCharacters)!)!.resize(size: CGSize(width: 100, height: 100), scale: UIScreen.main.scale))
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
                        }.padding(.trailing, 8)
                    }
                }.padding()
            }
            HStack {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .frame(width: 24)
                        .imageScale(.large)
                        .padding(30)
                        .background(Color.red.opacity(0.2))
                        .foregroundColor(.red)
                        .clipShape(Circle())
                }
                .padding(.bottom, 30)
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
                Button(action: flashState) {
                    Image(systemName: flashMode == .on ? "bolt" : "bolt.slash")
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
