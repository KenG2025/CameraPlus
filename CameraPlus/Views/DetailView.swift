//
//  DetailView.swift
//  LocationService
//
//  Created by Ken Gonzalez on 2/9/26.
//

import SwiftUI

struct DetailView: View {
    let entry: ProgressEntry

    @State private var showSlider = true

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Toggle between side-by-side and slider comparison
                Picker("Comparison", selection: $showSlider) {
                    Text("Slider").tag(true)
                    Text("Side-by-Side").tag(false)
                }
                .pickerStyle(.segmented)

                if showSlider {
                    ComparisonSliderView(beforeURL: entry.beforeURL, afterURL: entry.afterURL)
                        .frame(height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    HStack(spacing: 8) {
                        DiskImage(url: entry.beforeURL, placeholderSystemName: "photo")
                            .frame(height: 220)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        DiskImage(url: entry.afterURL, placeholderSystemName: "photo.fill")
                            .frame(height: 220)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(entry.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.headline)
                    if let note = entry.note, !note.isEmpty {
                        Text(note)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("No progress note.")
                            .font(.body)
                            .foregroundStyle(.tertiary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
        }
        .navigationTitle("Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}
