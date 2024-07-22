//
//  EditViewTransition.swift
//  luminous
//
//  Created by kureha8827 on 2024/07/03.
//

import SwiftUI

enum EditPath: Hashable {
    case edit, photosPicker(index: Int), editor

    @MainActor @ViewBuilder
    func Destination(path: Binding<NavigationPath>) -> some View {
        switch self {
        case .edit: EditView()
        case .photosPicker(let index): PhotosPickerView(albumIndex: index, path: path)
        case .editor: EditorView(path: path)
        }
    }
}
