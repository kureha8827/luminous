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
    static var isShowPhotos = false
    @State private var scrollCount: Int = 0

    // MemberwiseInitializerを無効にするため
    init(albumIndex: Int, path: Binding<NavigationPath>) {
        self.albumIndex = albumIndex
        self._path = path
    }
    var body: some View {
        ZStack {
            if Self.isShowPhotos {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 2) {
                        if (photoData.uiImages.count > albumIndex) {
                            ForEach(Array(photoData.uiImages[albumIndex].enumerated()), id: \.element) { index, image in
                                Button {
                                    Task {
                                        // editor.uiImageの[0]と[1]に最初の画像をいれる
                                        // [0]はtemp的なもの、[1]は変更用
                                        editor.uiImage += [photoData.fetchOriginalImage([albumIndex, index])]
                                        editor.uiImage += [editor.uiImage[editor.uiImageNode]]
//                                        editor.uiImageNode += 1
                                        withAnimation(Animation.easeOut(duration: 0.2)) {
                                            main.isShowTabBar = false
                                        }
                                        editor.isEditing = true
                                        try await Task.sleep(for: .seconds(0.2))
                                        path.append(EditPath.editor)
                                    }
                                } label: {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: DisplayInfo.width / 4, height: DisplayInfo.width / 4)
                                        .clipped()
                                        .onAppear() {
                                            // 最後の要素が見えたら続きの写真を表示
                                            if (image == photoData.uiImages[albumIndex].last && index >= 300*scrollCount + 299) {
                                                scrollCount += 1
                                                let _ = photoData.fetchPhotos(albumIndex, scrollCount)
                                            }
                                        }
                                }
                            }
                        } else {
                            Color.white
                        }
                    }
                    .navigationBarBackButtonHidden(true)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear() {
            if photoData.isFirstPhotosPickerView[albumIndex] {

                // 取得が完了したら写真一覧を表示
                Self.isShowPhotos = photoData.fetchPhotos(albumIndex, scrollCount)

                // 最初の取得の終了を記録
                photoData.isFirstPhotosPickerView[albumIndex] = false

            }
        }
        .onDisappear() {
        }
        .onChange(of: main.selectedTag) {
            path.removeLast(path.count)
        }
    }
}
