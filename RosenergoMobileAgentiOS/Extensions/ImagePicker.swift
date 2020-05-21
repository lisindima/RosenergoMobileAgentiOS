//
//  ImagePicker.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 11.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    
    @EnvironmentObject var sessionStore: SessionStore
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = context.coordinator
        imagePicker.sourceType = .camera
        imagePicker.cameraFlashMode = .off
        return imagePicker
    }
    
    func makeCoordinator() -> ImagePicker.Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ photoPicker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            photoPicker.dismiss(animated: true)
            let inspectionsImage = info[.originalImage] as! UIImage
            
            let imageView = UIImageView(image: inspectionsImage)
            imageView.backgroundColor = UIColor.clear
            imageView.frame = CGRect(x: 0, y: 0, width: inspectionsImage.size.width, height: inspectionsImage.size.height)
            
            let label = UILabel(frame: CGRect(x: -10, y: 10, width: inspectionsImage.size.width, height: inspectionsImage.size.height))
            label.backgroundColor = UIColor.clear
            label.textAlignment = .center
            label.textColor = UIColor.green
            label.text = "GDGOSDGS0GS0DG"
            
            UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0)
            imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
            label.layer.render(in: UIGraphicsGetCurrentContext()!)
            let imageWithText = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            let inspectionsImageData = imageWithText!.jpegData(compressionQuality: 0.8)?.base64EncodedString()
            parent.sessionStore.imageLocalInspections.append(inspectionsImageData!)
        }
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
}
