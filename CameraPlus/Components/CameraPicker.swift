//
//  CameraPicker.swift
//  CameraPlus
//
//  Created by Ken Gonzalez on 2/5/26.
//

import SwiftUI
import UIKit

struct CameraPicker: UIViewControllerRepresentable{
   
    
    let onImagePicked: (UIImage)-> Void
    @Environment(\.dismiss) private var dismiss
    
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
         let picker = UIImagePickerController()
        
        picker.sourceType = .camera
        picker.allowsEditing = false
        picker.delegate = context.coordinator
        
        return picker
        
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator{
        Coordinator(onImagePicked: onImagePicked, dismiss: dismiss)
    }
    
    class Coordinator: NSObject,UINavigationControllerDelegate,UIImagePickerControllerDelegate {
        
        let onImagePicked: (UIImage) -> Void
        let dismiss: DismissAction
        
        init(onImagePicked: @escaping (UIImage) -> Void, dismiss: DismissAction) {
            self.onImagePicked = onImagePicked
            self.dismiss = dismiss
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            if let image = info[.originalImage] as? UIImage {
                onImagePicked(image)
            }
            dismiss()
            
        }
        
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                dismiss()
        }
        
        
    }
}
