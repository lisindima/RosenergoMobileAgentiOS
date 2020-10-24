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
    @Binding var photosURL: [URL]
    
    private func stringDate() -> String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .autoupdatingCurrent
        dateFormatter.setLocalizedDateFormatFromTemplate("yyyy-MM-dd HH:mm:ss")
        dateFormatter.timeZone = .autoupdatingCurrent
        let createStringDate = dateFormatter.string(from: currentDate)
        return createStringDate
    }
    
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
                let imageWithText = uiimage!.addText("Широта: \(parent.locationStore.latitude)\nДолгота: \(parent.locationStore.longitude)\nДата: \(parent.stringDate())", point: CGPoint(x: 20, y: 20))
                let inspectionsImageData = imageWithText.jpegData(compressionQuality: 0)
                let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let filename = directory.appendingPathComponent("\(UUID().uuidString).png")
                try? inspectionsImageData?.write(to: filename)
                parent.photosURL.append(filename)
            }
        }
    }
}

struct CustomVideoRepresentable: UIViewControllerRepresentable {
    @EnvironmentObject private var sessionStore: SessionStore
    
    @Binding var startRecording: Bool
    @Binding var stopRecording: Bool
    @Binding var videoURL: URL?
    
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
                let filename = directory!.appendingPathComponent("\(UUID().uuidString).mp4")
                let data = try Data(contentsOf: outputFileURL, options: .mappedIfSafe)
                try data.write(to: filename)
                parent.videoURL = filename.absoluteURL
            } catch {
                log(error.localizedDescription)
            }
        }
    }
}
