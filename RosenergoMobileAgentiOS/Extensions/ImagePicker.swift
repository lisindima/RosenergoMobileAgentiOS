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
            let inspectionsImageData = inspectionsImage.jpegData(compressionQuality: 0)?.base64EncodedString(options: .lineLength64Characters)
            parent.sessionStore.photoParameters.append(PhotoParameters(latitude: parent.sessionStore.latitude, longitude: parent.sessionStore.longitude, file: inspectionsImageData!, maked_photo_at: parent.sessionStore.stringDate))
            parent.sessionStore.imageLocalInspections.append(inspectionsImageData!)
            print(parent.sessionStore.stringDate)
        }
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
}
