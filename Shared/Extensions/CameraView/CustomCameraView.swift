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
    @EnvironmentObject private var sessionStore: SessionStore
    @Environment(\.presentationMode) private var presentationMode
    
    @Binding var showRecordVideo: Bool
    @Binding var photosURL: [URL]
    @Binding var videoURL: URL?
    
    @State private var didTapCapture: Bool = false
    @State private var didTapCapture2: Bool = false
    @State private var choiceMode: CameraMode = .photo
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
                #if targetEnvironment(simulator) || targetEnvironment(macCatalyst)
                Color.green
                    .ignoresSafeArea(edges: .all)
                #else
                if choiceMode == .photo {
                    CustomCameraRepresentable(didTapCapture: $didTapCapture, flashMode: $flashMode, photosURL: $photosURL)
                        .ignoresSafeArea(edges: .all)
                }
                #endif
                VStack {
                    if choiceMode == .photo {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(photosURL.reversed(), id: \.self) { photo in
                                    LocalImage(data: try! Data(contentsOf: photo))
                                        .animation(.interactiveSpring())
                                        .contextMenu {
                                            Button(action: {
                                                if let index = photosURL.firstIndex(of: photo) {
                                                    photosURL.remove(at: index)
                                                }
                                            }) {
                                                Label("Удалить", systemImage: "trash")
                                            }
                                        }
                                }
                            }.padding()
                        }
                    }
                    HStack {
                        Button(action: {}) {
                            Image(systemName: "arrow.triangle.2.circlepath.camera")
                                .frame(width: 24)
                                .imageScale(.large)
                                .padding(20)
                                .background(Color.rosenergo.opacity(0.5))
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                        .padding(.horizontal)
                        .opacity(0.0)
                        .disabled(true)
                        Spacer()
                        Button(action: { didTapCapture = true }) {
                            Image(systemName: choiceMode == .photo ? "camera" : "video")
                                .frame(width: 24)
                                .imageScale(.large)
                                .padding(20)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                        Spacer()
                        if choiceMode == .photo {
                            Button(action: flashState) {
                                Image(systemName: setImageFlashButton)
                                    .frame(width: 24)
                                    .imageScale(.large)
                                    .padding(20)
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
                        Text("Закрыть")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    if showRecordVideo {
                        Picker("", selection: $choiceMode) {
                            Image(systemName: "camera")
                                .tag(CameraMode.photo)
                            Image(systemName: "video")
                                .tag(CameraMode.video)
                        }
                        .labelsHidden()
                        .pickerStyle(InlinePickerStyle())
                    }
                }
            }
        }
    }
}
