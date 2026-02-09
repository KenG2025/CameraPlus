//
//  Untitled.swift
//  CameraPlus
//
//  Created by Ken Gonzalez on 2/5/26.
//


import SwiftUI

struct EntryDetailView: View {

    let entry: ProgressEntry
    private let imageStore = ImageFileStore()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                Text(entry.createdAt, style: .date)
                    .font(.title2)
                    .bold()

                VStack(alignment: .leading, spacing: 12) {

                    Text("Before").font(.headline)
                    photoBox(fileName: entry.beforeImage)

                    Text("After").font(.headline)
                    photoBox(fileName: entry.afterImage)
                }

                if entry.note?.isEmpty == false {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Note").font(.headline)

                        Text(entry.note!)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.secondary.opacity(0.4))
                            )
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Entry Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func photoBox(fileName: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6]))
                .frame(height: 260)

            if let img = imageStore.loadIMG(fileName: fileName) {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 260)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                Text("Image not found")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
