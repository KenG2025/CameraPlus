//
//  ContentView.swift
//  CameraPlus
//
//  Created by Ken Gonzalez on 2/5/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            FeedView()
            AddEntryView()
            
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
