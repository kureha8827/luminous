//
//  PhotosPickerView.swift
//  luminous
//
//  Created by kureha8827 on 2024/06/30.
//

import SwiftUI

struct PhotosPickerView: View {
    var albumIndex: Int = 0
    @EnvironmentObject var photoLibraryFetcher: PhotoLibraryFetcher
    @State private var isShowPhotos = false

    // MemberwiseInitializerを無効にするため
    init(albumIndex: Int) {
        self.albumIndex = albumIndex
    }
    var body: some View {
        ZStack {
            if isShowPhotos {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                        let _ = print("photoLibraryFetcher.uiImages: \(photoLibraryFetcher.uiImages)")
                        let _ = print("photoLibraryFetcher.uiImages[albumIndex]: \(photoLibraryFetcher.uiImages[albumIndex])")
                        ForEach(photoLibraryFetcher.uiImages[albumIndex], id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipped()
                        }
                    }
                }
            }
        }
        .onAppear() {
            isShowPhotos = photoLibraryFetcher.fetchPhotos(idx: albumIndex)
        }
    }
}
