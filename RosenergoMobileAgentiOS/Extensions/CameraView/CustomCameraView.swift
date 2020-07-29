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
    
    @State private var didTapCapture2: Bool = false
    @State private var didTapCapture: Bool = false
    @State private var choiceMode: Int = 0
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
        NavigationView {
            ZStack(alignment: .bottom) {
                #if targetEnvironment(simulator)
                Color.green
                    .ignoresSafeArea(edges: .all)
                #else
                if choiceMode == 0 {
                    CustomCameraRepresentable(didTapCapture: $didTapCapture, flashMode: $flashMode)
                        .ignoresSafeArea(edges: .all)
                } else {
                    CustomVideoRepresentable(startRecording: $didTapCapture, stopRecording: $didTapCapture2)
                        .ignoresSafeArea(edges: .all)
                }
                #endif
                VStack {
                    if choiceMode == 0 {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(sessionStore.photosData.reversed(), id: \.self) { photo in
                                    NavigationLink(destination: CustomCameraImageDetails(photos: sessionStore.photosData)) {
                                        Image(uiImage: UIImage(data: photo)!.resizedImage(width: 100, height: 100))
                                            .renderingMode(.original)
                                            .resizable()
                                            .frame(width: 100, height: 100)
                                            .cornerRadius(10)
                                    }
                                }
                            }.padding()
                        }
                    }
                    HStack {
                        Button(action: { didTapCapture2 = true }) {
                            Image(systemName: "arrow.triangle.2.circlepath.camera")
                                .frame(width: 24)
                                .imageScale(.large)
                                .padding(30)
                                .background(Color.rosenergo.opacity(0.5))
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }.padding(.horizontal)
                        Spacer()
                        Button(action: { didTapCapture = true }) {
                            Image(systemName: choiceMode == 0 ? "camera" : "video")
                                .frame(width: 24)
                                .imageScale(.large)
                                .padding(30)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                        Spacer()
                        if choiceMode == 0 {
                            Button(action: flashState) {
                                Image(systemName: setImageFlashButton)
                                    .frame(width: 24)
                                    .imageScale(.large)
                                    .padding(30)
                                    .background(Color.rosenergo.opacity(0.5))
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                            }.padding(.horizontal)
                        }
                    }.padding(.bottom)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Picker("", selection: $choiceMode) {
                        Image(systemName: "camera")
                            .tag(0)
                        Image(systemName: "video")
                            .tag(1)
                    }
                    .labelsHidden()
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
        }
    }
}

struct CustomCameraImageDetails: View {
    
    @GestureState var scale: CGFloat = 1.0
    @State private var selectionImage: Int = 1
    
    var photos: [Data]
    
    var body: some View {
        TabView(selection: $selectionImage) {
            ForEach(photos.reversed(), id: \.self) { photo in
                Image(uiImage: UIImage(data: photo)!)
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
}
