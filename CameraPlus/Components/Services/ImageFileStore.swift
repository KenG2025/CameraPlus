//
//  ImageFileStore.swift
//  CameraPlus
//
//  Created by Ken Gonzalez on 2/5/26.
//

import Foundation
import UIKit

class ImageFileStore {
    
    private let folderName: String = "CameraDemoStorage"
    
    
    enum Kind {
        case before
        case after
    }

    
    // photo1_before.jpg
    // photo2_after.jpg
    
    // Creates a image name from before or after
    func makeFileName(id:UUID, kind: Kind) -> String{
        
        if kind == .before {
            // 10BC1LOP_before.jpg
            return id.uuidString + "_before.jpg"
        } else{
            return id.uuidString + "_after.jpg"
        }
    }
    
    // IMAGE TO DATA
    func saveIMG(_ image:UIImage,fileName:String) throws {
        guard let data = image.jpegData(compressionQuality: 0.9) else {
            throw NSError(
                domain: "CameraDemoStorage", code: 1, userInfo: [NSLocalizedDescriptionKey:"Could not convert image into DATA"]
            )
        }
        
        let url = fileURL(fileName: fileName)
        try data.write(to: url, options: .atomic)
        
    }
    
    // DATA TO IMAGE
    func loadIMG(fileName:String)-> UIImage?{
        let url = fileURL(fileName: fileName)
        
        // The file exist ???
        if FileManager.default.fileExists(atPath: url.path()) == false {
            return nil
        }
        
        // Any errors from damage information
        guard let data = try? Data(contentsOf: url) else {return nil}
        
        // Parsing data to IMAGE
        return UIImage(data: data)
        
    }
    
    
    
    func deleteIMG(fileName:String){
        let url = fileURL(fileName: fileName)
        
        // The file exist ???
        if FileManager.default.fileExists(atPath: url.path()) == false {
            return
        }
        
        try? FileManager.default.removeItem(at: url)
        
    }
    
    
    func createFolderIfNeeded(){
        let url = folderURL()
        
        if FileManager.default.fileExists(atPath:url.path()){
            return
        }
        
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        
    }
    
    
    
    // Folder/route/filename.jpg
    
    //Create Folder URL
    func docURL()->URL{
        // create a folder for this APP in user's phone
        FileManager.default.urls(for:.documentDirectory, in: .userDomainMask)[0]
    }
    
    func folderURL ()-> URL {
        // on users Local Storage create a path to this folder
        docURL().appendingPathComponent(folderName)
        // Documents/users/CameraDemoStorage/(filename)
    }
    
    func fileURL(fileName:String) -> URL {
        // Documents/users/CameraDemoStorage/(filename)
        docURL().appendingPathComponent(fileName)
    }

}
