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
            let inspectionsImageData = inspectionsImage.jpegData(compressionQuality: 0.8)
            parent.sessionStore.imageLocalInspections.append(inspectionsImageData!)
            print(parent.sessionStore.imageLocalInspections)
        }
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
}
