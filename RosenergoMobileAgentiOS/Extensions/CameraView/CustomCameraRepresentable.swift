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
    @ObservedObject private var locationStore = LocationStore.shared
    @EnvironmentObject var sessionStore: SessionStore
    
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
                let imageWithText = uiimage!.addText(text: "Широта: \(parent.locationStore.latitude)\nДолгота: \(parent.locationStore.longitude)\nДата: \(parent.sessionStore.stringDate())", point: CGPoint(x: 20, y: 20))
                let inspectionsImageData = imageWithText.jpegData(compressionQuality: 0)
                let file = inspectionsImageData!.base64EncodedString()
                parent.sessionStore.photoParameters.append(PhotoParameters(latitude: parent.locationStore.latitude, longitude: parent.locationStore.longitude, file: file, maked_photo_at: parent.sessionStore.stringDate()))
            }
        }
    }
}

extension UIImage {
    func addText(text: String, point: CGPoint) -> UIImage {
        let textColor = UIColor(named: "textColor")
        let textFont = UIFont(name: "Helvetica Bold", size: 40)!
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        
        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor!,
        ] as [NSAttributedString.Key: Any]
        
        draw(in: CGRect(origin: CGPoint.zero, size: size))
        let rect = CGRect(origin: point, size: size)
        text.draw(in: rect, withAttributes: textFontAttributes)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func resize(size: CGSize, scale: CGFloat) -> UIImage {
        let targetSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
