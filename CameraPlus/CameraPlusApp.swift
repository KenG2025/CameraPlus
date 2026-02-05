//
//  CameraPlusApp.swift
//  CameraPlus
//
//  Created by Ken Gonzalez on 2/5/26.
//

import SwiftUI
import SwiftData

import SwiftUI
import SwiftData

@main
struct CameraTestApp: App {
    var body: some Scene {
        
        WindowGroup {
            ContentView()
        }
        .modelContainer(for:ProgressEntry.self)
    }
}
