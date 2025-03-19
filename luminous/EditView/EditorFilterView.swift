//
//  EditorFilterView.swift
//  luminous
//
//  Created by kureha8827 on 2024/07/04.
//

import SwiftUI

struct EditorFilterView: View {
    @EnvironmentObject var editor: Editor
    @State private var sliderValue: Int = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                HStack(spacing: 0) {
                    Button {    // originalフィルタ
                        Task { @MainActor in
                            editor.currentFilter = 0
                            editor.filterSize = Array(repeating: 0, count: ConstStruct.filterNum)
                        }
                    } label: {
                        ImageItemView(
                            type: .filter,
                            viewType: .editor,
                            item: 0,
                            valueStr: String(editor.filterSize[0]),
                            photo: PhotoArray().imgFilter
                        )
                    }

                    // 縦線
                    Rectangle()
                        .frame(width: 1, height: 48)
                        .padding(.leading, 6)
                        .foregroundStyle(.gray63)
                        .offset(y: -12)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            // 以下の警告に対応するために id: \.self を追加
                            // Non-constant range: argument must be an integer literal
                            ForEach(1..<ConstStruct.filterNum, id: \.self) { i in   // 1からの番号を渡す(0はoriginal)
                                Button() {
                                    if editor.currentFilter == i {
                                        sliderValue = 0
                                    } else {
                                        Task { @MainActor in
                                            editor.currentFilter = i
                                            sliderValue = editor.filterSize[editor.currentFilter]
                                        }
                                    }
                                } label: {
                                    ImageItemView(
                                        type: .filter,
                                        viewType: .editor,
                                        item: i,
                                        valueStr: String(editor.filterSize[i]),
                                        photo: PhotoArray().imgFilter
                                    )
                                }
                            }
                        }
                        // HStackのspacing(12)
                        .padding(.leading, 6)
                        .padding(.trailing, 8)
                    }
                }
                .offset(y: 12)
                .padding(.leading, 8)

                if editor.currentFilter >= 1 {
                    PositiveSlider(value: $sliderValue, width: 220)
                        .frame(width: 220)
                        .rotationEffect(.degrees(-90))
                        .offset(x: geometry.frame(in: .local).midX - 18, y: -180)
                }
            }
        }
        .onAppear() {
            // FIXME: ifでもし変更があった場合と条件をつける. EditorAdjusterも同様.
            editor.uiImage += [editor.uiImage[editor.uiImageNode]]
            editor.uiImageNode += 1
        }
        .onChange(of: sliderValue) {
            // スライダの値を取得しEditorに代入
            editor.filterSize[editor.currentFilter] = sliderValue
            editor.edit()
        }
    }
}
