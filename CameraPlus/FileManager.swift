//
//  FileManager.swift
//  LocationService
//
//  Created by Ken Gonzalez on 2/6/26.
//

import Foundation


extension FileManager {
    var documentsURL: URL? {
        urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    func saveJPEG(_ data: Data, suggestedName: String) throws -> String {
        let fileName = "\(UUID().uuidString)_\(suggestedName)jpg"
        guard let base = documentsURL else {
            throw NSError(domain: "DocumentsDir", code: 1)
        }
        
        let url = base.appendingPathComponent(fileName); try data.write(to: url, options: .atomic)
        return fileName
    }
    
    func deleteFileIfExsists(atRelativePath path: String){
        guard let base = documentsURL else {return}
        let url = base.appendingPathComponent(path)
        if fileExists(atPath: url.path) {
            try? removeItem(at: url)
            }
        }
    }

