
//
//  EditView.swift
//  luminous
//
//  Created by kureha8827 on 2024/03/25.
//

import SwiftUI
import PhotosUI

struct EditView: View {
    @EnvironmentObject var editor: Editor
    @EnvironmentObject var photoData: PhotoLibraryFetcher
    @EnvironmentObject var vs: ViewSwitcher
    @EnvironmentObject var main: MainObserver
    @Environment(\.dismiss) var dismiss
    @State private var path: NavigationPath = NavigationPath()
    private var access = PhotoLibraryAccess()
    @State private var isAuthorized = false
    @State private var isShowPhotoView = false
    @State private var isBack = false
    static var isFirst = true

    var body: some View {
        let swipeGesture = DragGesture()
            .onEnded { gesture in
                if !editor.isEditing {
                    isShowPhotoView = gesture.translation.width < 0 ? true : false
                    isBack = gesture.translation.width > 0 ? true : false
                }
            }

        NavigationStack(path: $path) {
            if isAuthorized {
                List {
                    ForEach(Array(photoData.albums.enumerated()), id: \.element) { index, data in
                        NavigationLink(value: EditPath.photosPicker(index: index)) {
                            HStack(spacing: 8) {
                                Image(uiImage: data.thumbnail)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 64, height: 64)
                                    .clipped()
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(data.name)
                                        .font(.system(size: 20))
                                        .foregroundStyle(.gray63)
                                    Text("\(data.quantity)枚")
                                        .font(.system(size: 14))
                                        .foregroundStyle(.gray)

                                }
                            }
                            .frame(height: 80)
                        }
                        .navigationDestination(for: EditPath.self) { appended in
                            appended.Destination(path: $path)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white)
        .gesture(swipeGesture)
        .onAppear() {
            access.requestPermission { authorized in
                isAuthorized = authorized
                if authorized {
                    if Self.isFirst {
                        photoData.fetchAlbumsData()
                        Self.isFirst = false
                    }
                }
            }
        }
        .onChange(of: isShowPhotoView) {
            if isShowPhotoView {
                isShowPhotoView = false
                main.selectedTag = 1
            }
        }
        .onChange(of: isBack) {
            if isBack {
                isBack = false
                if (path.count > 0) {
                    path.removeLast()
                }
            }
        }
    }
}
