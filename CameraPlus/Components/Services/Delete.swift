//
//  Delete.swift
//  CameraPlus
//
//  Created by Ken Gonzalez on 2/9/26.
//

import Foundation

extension FileManager {
    /// Deletes a file at the given relative path (relative to the app's documents directory) if it exists.
    /// Silently ignores missing files and logs other errors.
    func deleteFileIfExists(atRelativePath relativePath: String?) {
        guard let relativePath, !relativePath.isEmpty else { return }
        
        do {
            let documentsURL = try url(for: .documentDirectory,
                                       in: .userDomainMask,
                                       appropriateFor: nil,
                                       create: false)
            let fileURL = documentsURL.appendingPathComponent(relativePath)

            if fileExists(atPath: fileURL.path) {
                do {
                    try removeItem(at: fileURL)
                } catch {
                    // You can replace this with your app's logging
                    print("Failed to delete file at \(fileURL): \(error)")
                }
            }
        } catch {
            // You can replace this with your app's logging
            print("Failed to resolve documents directory: \(error)")
        }
    }
}
