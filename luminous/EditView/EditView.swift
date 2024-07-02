
//
//  EditView.swift
//  luminous
//
//  Created by kureha8827 on 2024/03/25.
//

import SwiftUI
import PhotosUI

struct EditView: View {
    @EnvironmentObject var edit: EditClass
    @EnvironmentObject var photoLibraryFetcher: PhotoLibraryFetcher
    @EnvironmentObject var vs: ViewSwitcher
    @EnvironmentObject var main: MainClass
    private var photoLibraryAccess = PhotoLibraryAccess()
    @State private var isAuthorized = false
    @State private var isShowPhotoView = false

    var body: some View {
        let swipeGesture = DragGesture()
            .onEnded { gesture in
                isShowPhotoView = gesture.translation.width < 0 ? true : false
            }

        ZStack {
            if isAuthorized {
                List {
                    ForEach(Array(photoLibraryFetcher.albums.enumerated()), id: \.element) { index, title in
                        NavigationLink {
                            PhotosPickerView(albumIndex: index)
                        } label: {
                            Text(title)
                                .font(.system(size: 20))
                                .foregroundStyle(.gray63)
                                .frame(height: 80)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white)
        .gesture(swipeGesture)
        .onAppear() {
            photoLibraryAccess.requestPermission { authorized in
                isAuthorized = authorized
                if authorized {
                    photoLibraryFetcher.fetchAlbumsName()
                }
            }
        }
        .onChange(of: isShowPhotoView) {
            if isShowPhotoView {
                isShowPhotoView = false
                main.selectedTag = 1
            }
        }
    }
}
