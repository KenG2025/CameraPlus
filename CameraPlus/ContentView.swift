//
//  ContentView.swift
//  CameraPlus
//
//  Created by Ken Gonzalez on 2/5/26.
//

import SwiftUI
import SwiftData


struct ContentView: View {
    var body: some View {
        ZStack{
            VStack {
                FeedView()
                AddEntryView()
                BeforeAfterDetailView()
                MainListView()
            }
            .padding()
            .fontWeight(.bold)
        }
        .foregroundStyle(.yellow)
        .background(.gray)
        
        
        
        
    }
}

#Preview {
    ContentView()
}
