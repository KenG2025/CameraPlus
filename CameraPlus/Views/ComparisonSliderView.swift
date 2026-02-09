//
//  ComparisonSliderView.swift
//  LocationService
//
//  Created by Ken Gonzalez on 2/7/26.
//

import SwiftUI

struct ComparisonSliderView: View {
    let beforeURL: URL?
    let afterURL: URL?

    @State private var slider: CGFloat = 0.5

    var body: some View {
        GeometryReader { geo in
            ZStack {
                DiskImage(url: beforeURL, placeholderSystemName: "photo")
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()

                DiskImage(url: afterURL, placeholderSystemName: "photo.fill")
                    .frame(width: geo.size.width, height: geo.size.height)
                    .mask(
                        Rectangle()
                            .frame(width: geo.size.width * slider)
                            .alignmentGuide(.leading) { d in d[.leading] }
                    )

                // Slider handle
                Rectangle()
                    .fill(.white)
                    .frame(width: 2)
                    .shadow(radius: 2)
                    .position(x: geo.size.width * slider, y: geo.size.height / 2)
                
                // Drag gesture to move the slider
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let x = max(0, min(value.location.x, geo.size.width))
                                slider = x / geo.size.width
                            }
                    )
            }
        }
        .accessibilityLabel("Before and After comparison slider")
        .accessibilityValue("\(Int(slider * 100)) percent")
    }
}

