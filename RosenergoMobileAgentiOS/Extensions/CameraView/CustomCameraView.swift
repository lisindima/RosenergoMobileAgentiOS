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
    
    @EnvironmentObject private var sessionStore: SessionStore
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var didTapCapture: Bool = false
    @State private var changeCamera: Bool = false
    @State private var flashMode: AVCaptureDevice.FlashMode = .off
    
    func flashState() {
        if flashMode == .on {
            flashMode = .off
        } else if flashMode == .off {
            flashMode = .on
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            #if targetEnvironment(simulator)
            Color.green
                .ignoresSafeArea(edges: .all)
            #else
            CustomCameraRepresentable(didTapCapture: $didTapCapture, changeCamera: $changeCamera, flashMode: $flashMode)
                .ignoresSafeArea(edges: .all)
            #endif
            VStack(alignment: .trailing) {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                }.offset(x: -20, y: 50)
                Spacer()
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(sessionStore.photosData.reversed(), id: \.self) { photo in
                            ZStack {
                                Image(uiImage: UIImage(data: photo)!.resizedImage(width: 100, height: 100))
                                    .renderingMode(.original)
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(10)
                                Button(action: {
                                    if let index = sessionStore.photosData.firstIndex(of: photo) {
                                        sessionStore.photosData.remove(at: index)
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
                    Button(action: { changeCamera = true }) {
                        Image(systemName: "arrow.triangle.2.circlepath.camera")
                            .frame(width: 24)
                            .imageScale(.large)
                            .padding(30)
                            .background(Color.rosenergo.opacity(0.4))
                            .foregroundColor(.rosenergo)
                            .clipShape(Circle())
                    }.padding(.horizontal)
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
                        Image(systemName: flashMode == .on ? "bolt" : "bolt.slash")
                            .frame(width: 24)
                            .imageScale(.large)
                            .padding(30)
                            .background(Color.rosenergo.opacity(0.4))
                            .foregroundColor(.rosenergo)
                            .clipShape(Circle())
                    }.padding(.horizontal)
                }.padding(.bottom, 30)
            }
        }
    }
}
