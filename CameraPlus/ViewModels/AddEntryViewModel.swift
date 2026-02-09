//
//  AddEntryViewModel.swift
//  CameraPlus
//
//  Created by Ken Gonzalez on 2/5/26.
//

import Foundation
import SwiftData
import PhotosUI
import UIKit
import _PhotosUI_SwiftUI
import Combine


@MainActor
class AddEntryViewModel: ObservableObject{
    
    @Published var note: String = ""
    @Published var beforeImage: UIImage? = nil
    @Published var afterImage: UIImage? = nil

    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    
    @Published var beforeURL: URL?
    @Published var afterURL: URL?
    
    let imageStore = ImageFileStore()
    
    
    func setBeforePickerItem(_ item: PhotosPickerItem?){
        loadUIImage(from: item){ [weak self] image in
            self?.beforeImage = image
        }
    }
    
    func setAfterPickerItem(_ item: PhotosPickerItem?){
        loadUIImage(from: item){ [weak self] image in
            self?.afterImage = image
        }
    }
            
    
    //MARK: Take photo/Camera roll -> PhotoPickerItem -> UIImage(UIkit)
    func loadUIImage(from item:PhotosPickerItem?, completion:@escaping (UIImage?)->Void){
        guard let item else{
            completion(nil)
            return
        }
        Task{
            if let data = try? await item.loadTransferable(type: Data.self){
                let image = UIImage(data: data)
                completion(image)
            }else{
                completion(nil)
            }
        }
    }
    

    // Making sure the image is valid and it is not nil
    func canSave()->Bool{
        return beforeImage != nil && afterImage != nil
    }
    
    
    func save(modelContext: ModelContext) ->Bool{
        
        guard let beforeImage, let afterImage else {
            errorMessage = "select both photos"
            showError = true
            return false
        }
        
        let id = UUID()
        
        let beforeName = imageStore.makeFileName(id: id, kind: .before)
        let afterName = imageStore.makeFileName(id: id, kind: .after)

        do{
            try imageStore.saveIMG(beforeImage,fileName: beforeName)
            try imageStore.saveIMG(afterImage, fileName: afterName)
        } catch{
            
            errorMessage = "Could not save image"
            showError = true
            return false
            
        }
        
        let entry = ProgressEntry(
            id:id,
            createdAt: Date(),
            note: note,
            beforeImage: beforeName,
            afterImage: afterName,
            beforeURL: beforeURL,
            afterURL: afterURL
        )
        
        modelContext.insert(entry)
        
        
        do{
            try modelContext.save()
        }catch{
            errorMessage = "Could not save entry"
            showError = true
            return false
        }
        return true
    }
    
}
