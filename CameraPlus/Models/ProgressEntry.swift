//
//  ProgressEntry.swift
//  CameraPlus
//
//  Created by Ken Gonzalez on 2/5/26.
//

import Foundation
import SwiftData


@Model
class ProgressEntry{
    var id: UUID
    var createdAt: Date
    var note: String?
    
    var beforeImage:String
    var afterImage:String
    
    var beforeURL: URL?
    var afterURL: URL?
    
    init(id: UUID = UUID(), createdAt: Date = Date(), note: String?, beforeImage: String, afterImage: String, beforeURL: URL?, afterURL: URL?) {
        self.id = id
        self.createdAt = createdAt
        self.note = note
        self.beforeImage = beforeImage
        self.afterImage = afterImage
        self.beforeURL = beforeURL
        self.afterURL = afterURL
    }
    
}
