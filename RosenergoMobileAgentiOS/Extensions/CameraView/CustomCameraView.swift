//
//  CustomCameraView.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 29.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import AVFoundation
import SwiftUI

struct CustomCameraView: View {
    @EnvironmentObject var sessionStore: SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    @State private var didTapCapture: Bool = false
    @State private var flashMode: AVCaptureDevice.FlashMode = .auto
    @State private var setImageFlashButton: String = "bolt.badge.a"
    
    func flashState() {
        if flashMode == .auto {
            flashMode = .on
            setImageFlashButton = "bolt"
        } else if flashMode == .on {
            flashMode = .off
            setImageFlashButton = "bolt.slash"
        } else if flashMode == .off {
            flashMode = .auto
            setImageFlashButton = "bolt.badge.a"
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            #if targetEnvironment(simulator)
            Color.green
                .edgesIgnoringSafeArea(.all)
            #else
            CustomCameraRepresentable(didTapCapture: $didTapCapture, flashMode: $flashMode)
                .edgesIgnoringSafeArea(.all)
            #endif
            VStack(alignment: .trailing) {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                }.offset(x: -20, y: 30)
                Spacer()
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
                                    if let index = sessionStore.photoParameters.firstIndex(of: photo) {
                                        sessionStore.photoParameters.remove(at: index)
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
                    Image(systemName: "xmark")
                        .frame(width: 24)
                        .imageScale(.large)
                        .padding(30)
                        .background(Color.clear.opacity(0.0))
                        .foregroundColor(.clear)
                        .clipShape(Circle())
                        .padding(.horizontal)
                    Spacer()
                    Button(action: { didTapCapture = true }) {
                        Image(systemName: "camera")
                            .frame(width: 24)
                            .imageScale(.large)
                            .padding(30)
                            .background(Color.rosenergo)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    Spacer()
                    Button(action: flashState) {
                        Image(systemName: setImageFlashButton)
                            .frame(width: 24)
                            .imageScale(.large)
                            .padding(30)
                            .background(Color.rosenergo.opacity(0.5))
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }.padding(.horizontal)
                }.padding(.bottom, 30)
            }
        }
    }
}
