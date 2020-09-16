//
//  CustomCameraRepresentable.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 29.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import AVFoundation
import SwiftUI

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
    
    func updateUIViewController(_ cameraViewController: CustomCameraController, context _: Context) {
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
        
        func photoOutput(_: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error _: Error?) {
            parent.didTapCapture = false
            if let imageData = photo.fileDataRepresentation() {
                let uiimage = UIImage(data: imageData)
                let imageWithText = uiimage!.addText("Широта: \(parent.locationStore.latitude)\nДолгота: \(parent.locationStore.longitude)\nДата: \(stringDate())", point: CGPoint(x: 20, y: 20))
                let inspectionsImageData = imageWithText.jpegData(compressionQuality: 0)
                let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let filename = directory.appendingPathComponent("\(stringDate()).png")
                try? inspectionsImageData?.write(to: filename)
                parent.sessionStore.photosURL.append(filename)
            }
        }
    }
}

struct CustomVideoRepresentable: UIViewControllerRepresentable {
    @EnvironmentObject private var sessionStore: SessionStore
    
    @Binding var startRecording: Bool
    @Binding var stopRecording: Bool
    
    func makeUIViewController(context: Context) -> CustomVideoController {
        let controller = CustomVideoController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ customVideoController: CustomVideoController, context _: Context) {
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
        
        func fileOutput(_: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from _: [AVCaptureConnection], error: Error?) {
            do {
                let directory = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
                let filename = directory!.appendingPathComponent("video_\(Date()).mp4")
                let data = try Data(contentsOf: outputFileURL, options: .mappedIfSafe)
                try data.write(to: filename)
                parent.sessionStore.videoURL = filename.absoluteURL
            } catch {
                log(error.localizedDescription)
            }
        }
    }
}
