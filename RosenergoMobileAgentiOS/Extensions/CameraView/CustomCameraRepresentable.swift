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
    
    @EnvironmentObject var sessionStore: SessionStore
    @EnvironmentObject var locationStore: LocationStore
    
    @Binding var didTapCapture: Bool
    @Binding var changeCamera: Bool
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
        if changeCamera {
            cameraViewController.changeCamera()
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
                let imageWithText = uiimage!.addText(text: "Широта: \(parent.locationStore.currentLocation!.coordinate.latitude)\nДолгота: \(parent.locationStore.currentLocation!.coordinate.longitude)\nДата: \(parent.sessionStore.stringDate)", point: CGPoint(x: 20, y: 20))
                let inspectionsImageData = imageWithText.jpegData(compressionQuality: 0)
                parent.sessionStore.photosData.append(inspectionsImageData!)
            }
        }
    }
}
