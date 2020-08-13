//
//  CustomCameraRepresentable.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 29.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import AVFoundation

struct CustomCameraRepresentable: UIViewControllerRepresentable {
    
    @EnvironmentObject private var sessionStore: SessionStore
    @EnvironmentObject private var locationStore: LocationStore
    
    @Binding var didTapCapture: Bool
    @Binding var flashMode: AVCaptureDevice.FlashMode

    func makeUIViewController(context: Context) -> CustomCameraController {
        let controller = CustomCameraController()
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ cameraViewController: CustomCameraController, context: Context) {
        if didTapCapture {
            cameraViewController.didTapRecord(flashMode: flashMode)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, AVCapturePhotoCaptureDelegate {
        let parent: CustomCameraRepresentable

        init(_ parent: CustomCameraRepresentable) {
            self.parent = parent
        }

        func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            parent.didTapCapture = false
            if let imageData = photo.fileDataRepresentation() {
                let uiimage = UIImage(data: imageData)
                let imageWithText = uiimage!.addText("Широта: \(parent.locationStore.latitude)\nДолгота: \(parent.locationStore.longitude)\nДата: \(parent.sessionStore.stringDate())", point: CGPoint(x: 20, y: 20))
                let inspectionsImageData = imageWithText.jpegData(compressionQuality: 80)
                parent.sessionStore.photosData.append(inspectionsImageData!)
            }
        }
    }
}

struct CustomVideoRepresentable: UIViewControllerRepresentable {
    
    @EnvironmentObject private var sessionStore: SessionStore
    @EnvironmentObject private var locationStore: LocationStore
    
    @Binding var startRecording: Bool
    @Binding var stopRecording: Bool

    func makeUIViewController(context: Context) -> CustomVideoController {
        let controller = CustomVideoController()
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ customVideoController: CustomVideoController, context: Context) {
        if startRecording {
            customVideoController.startRecording()
        }
        if stopRecording {
            customVideoController.stopRecording()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, AVCaptureFileOutputRecordingDelegate {
        
        let parent: CustomVideoRepresentable

        init(_ parent: CustomVideoRepresentable) {
            self.parent = parent
        }
        
        func getDocumentsDirectory() -> URL {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            return paths[0]
        }
        
        func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
            do {
                let url = getDocumentsDirectory().appendingPathComponent("video.mp4")
                let data = try Data(contentsOf: outputFileURL, options: .mappedIfSafe)
                try data.write(to: url)
                parent.sessionStore.videoURL = url.absoluteString
            } catch  {
                print(error)
            }
        }
        
    }
}
