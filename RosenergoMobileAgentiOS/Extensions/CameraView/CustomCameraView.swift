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
                #if targetEnvironment(simulator) || targetEnvironment(macCatalyst)
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
                                ForEach(sessionStore.photosURL.reversed(), id: \.self) { photo in
                                    Image(uiImage: UIImage(data: try! Data(contentsOf: photo))!.resizedImage(width: 100, height: 100))
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                        .cornerRadius(8)
                                        .animation(.interactiveSpring())
                                        .contextMenu {
                                            Button(action: {
                                                if let index = sessionStore.photosURL.firstIndex(of: photo) {
                                                    sessionStore.photosURL.remove(at: index)
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
                            .imageScale(.large)
                            .foregroundColor(.secondary)
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    if showRecordVideo {
                        Picker("", selection: $choiceMode) {
                            Image(systemName: "camera")
                                .tag(0)
                            Image(systemName: "video")
                                .tag(1)
                        }
                        .labelsHidden()
                        .pickerStyle(InlinePickerStyle())
                    }
                }
            }
        }
    }
}
