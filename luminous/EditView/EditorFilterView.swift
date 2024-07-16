//
//  EditorFilterView.swift
//  luminous
//
//  Created by kureha8827 on 2024/07/04.
//

import SwiftUI

struct EditorFilterView: View {
    @EnvironmentObject var editor: Editor
    @State private var sliderValue: Float = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                HStack(spacing: 0) {
                    Button(action: {    // originalフィルタ
                        DispatchQueue.global().async {
                            editor.currentFilter = 0
                            editor.filterSize = Array(repeating: Float(0), count: ConstStruct.filterNum)
                        }
                    }, label: {
                        ImageItemView(
                            type: .filter,
                            viewType: .editor,
                            item: 0,
                            value: editor.filterSize[0],
                            photo: PhotoArray().imgFilter
                        )
                    })

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
                                Button(action: {
                                    if editor.currentFilter == i {
                                        sliderValue = 0
                                    } else {
                                        DispatchQueue.global().async {
                                            editor.currentFilter = i
                                            sliderValue = editor.filterSize[editor.currentFilter]
                                        }
                                    }
                                }, label: {
                                    ImageItemView(
                                        type: .filter,
                                        viewType: .editor,
                                        item: i,
                                        value: editor.filterSize[i],
                                        photo: PhotoArray().imgFilter
                                    )
                                })
                            }
                        }
                        .frame(height: 88)
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
        .onChange(of: sliderValue) {
            // スライダの値を取得しBaseCameraに代入
            editor.filterSize[editor.currentFilter] = sliderValue

            // 2つ以上のフィルタを同時に適用できなくしている
            if editor.filterSize[editor.currentFilter] != 0 {
                for i in 0..<ConstStruct.filterNum {
                    if i != editor.currentFilter {
                        editor.filterSize[i] = 0
                    }
                }
            }
        }
    }
}
