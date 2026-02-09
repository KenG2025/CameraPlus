//
//  ImageLoader.swift
//  LocationService
//
//  Created by Ken Gonzalez on 2/6/26.
//

import SwiftUI

struct ImageLoaderView: View {
    let url: URL?
    let placeHolderSystemName: String

    var body: some View {
        if let url,
           let img = UIImage(contentsOfFile: url.path) {
            AnyView(
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
            )
        } else {
            AnyView(
                Image(systemName: placeHolderSystemName)
                    .resizable()
                    .scaledToFit()
            )
        }
    }
}
