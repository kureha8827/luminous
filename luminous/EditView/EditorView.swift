//
//  EditorView.swift
//  luminous
//
//  Created by kureha8827 on 2024/07/03.
//

import SwiftUI

struct EditorView: View {
    @Binding var path: NavigationPath
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var editor: Editor
    @EnvironmentObject var main: MainObserver
//    @EnvironmentObject var photoData: PhotoLibraryFetcher
//    @EnvironmentObject var vs: ViewSwitcher
//    @Environment(\.dismiss) var dismiss
    var body: some View {
        ZStack {
            Image(uiImage: editor.uiImage ?? UIImage())
                .resizable()
                .frame(width: UIScreen.main.bounds.width)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(
                    action: {
                        dismiss()
                    }, label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16))
                            .tint(.gray63)
                    }
                )
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button() {
                    // TODO: 保存したときの動作
                } label: {
                    Image(systemName: "arrow.down.to.line.compact")
                        .font(.system(size: 20))
                        .tint(.gray63)
                        .padding(.bottom, 4)
                }
            }
        }
        .onAppear() {
            main.isShowTabBar = false
        }
        .onDisappear() {
            main.isShowTabBar = true
        }
    }
}
