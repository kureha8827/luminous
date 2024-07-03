//
//  PhotosPickerView.swift
//  luminous
//
//  Created by kureha8827 on 2024/06/30.
//

import SwiftUI

struct PhotosPickerView: View {
    var albumIndex: Int = 0
    @Binding var path: NavigationPath
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var editor: Editor
    @EnvironmentObject var main: MainObserver
    @EnvironmentObject var photoData: PhotoLibraryFetcher
    @Environment(\.presentationMode) var presentation
    @State private var isShowPhotos = false
    @State private var scrollCount: Int = 0

    // MemberwiseInitializerを無効にするため
    init(albumIndex: Int, path: Binding<NavigationPath>) {
        self.albumIndex = albumIndex
        self._path = path
    }
    var body: some View {
        ZStack {
            if isShowPhotos {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 2) {
                        ForEach(photoData.uiImages[albumIndex], id: \.self) { image in
                            NavigationLink(value: EditPath.editor) {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: UIScreen.main.bounds.width / 4, height: UIScreen.main.bounds.width / 4)
                                    .clipped()
                                    .onAppear() {
                                        // 最後の要素が見えたら続きの写真を表示
                                        if (image == photoData.uiImages[albumIndex].last) {
                                            scrollCount += 1
                                            let _ = photoData.fetchPhotos(albumIndex, scrollCount)
                                        }
                                    }
                            }
                            .navigationDestination(for: EditPath.self) { appended in
//                                editor.uiImage = image
                                appended.Destination(path: $path)
                            }
                        }
                    }
                    .navigationBarBackButtonHidden(true)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button() {
                                dismiss()
                            } label: {
                                HStack {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 16))
                                    Text("back")
                                        .font(.system(size: 20))
                                }
                                .tint(.gray63)
                            }
                        }
                    }
                }
            }
        }
        .onAppear() {
            isShowPhotos = photoData.fetchPhotos(albumIndex, scrollCount)
        }
        .onChange(of: main.selectedTag) {
            path.removeLast(path.count)
        }
    }
}
