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
    
    @Binding var didTapCapture: Bool
    @Binding var flashMode: AVCaptureDevice.FlashMode
    
    let dateOnImage: String = {
        var currentDate: Date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        let dateString = dateFormatter.string(from: currentDate)
        return dateString
    }()

    func makeUIViewController(context: Context) -> CustomCameraController {
        let controller = CustomCameraController()
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ cameraViewController: CustomCameraController, context: Context) {
        if self.didTapCapture {
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
                let imageWithText = uiimage!.addText(text: "Широта: \(parent.sessionStore.latitude)\nДолгота: \(parent.sessionStore.longitude)\nДата: \(parent.dateOnImage)", point: CGPoint(x: 20, y: 20))
                let inspectionsImageData = imageWithText.jpegData(compressionQuality: 0)
                let file = inspectionsImageData!.base64EncodedString()
                parent.sessionStore.photoParameters.append(PhotoParameters(latitude: parent.sessionStore.latitude, longitude: parent.sessionStore.longitude, file: file, maked_photo_at: parent.sessionStore.stringDate))
            }
        }
    }
}

extension UIImage {
    func addText(text: String, point: CGPoint) -> UIImage {
        let textColor = UIColor(named: "textColor")
        let textFont = UIFont(name: "Helvetica Bold", size: 40)!
        UIGraphicsBeginImageContextWithOptions(self.size, false, 1)
        
        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor!,
            ] as [NSAttributedString.Key : Any]
        
        self.draw(in: CGRect(origin: CGPoint.zero, size: self.size))
        let rect = CGRect(origin: point, size: self.size)
        text.draw(in: rect, withAttributes: textFontAttributes)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func resizedImage(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
