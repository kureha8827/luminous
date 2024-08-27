//
//  EditorBeautyView.swift
//  luminous
//
//  Created by kureha8827 on 2024/07/04.
//

import SwiftUI

// 顔加工
struct EditorBeautyView: View {
    @EnvironmentObject var editor: Editor

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            // 以下の警告に対応するために id: \.self を追加
                            // Non-constant range: argument must be an integer literal
                            ForEach(0..<ConstStruct.beautyNum, id: \.self) { i in   // 1からの番号を渡す(0はoriginal)
                                Button {
                                    if i == 0 {
                                        
                                    }
                                } label: {
                                    ImageItemView(
                                        type: .beauty,
                                        viewType: .editor,
                                        item: i,
                                        value: editor.beautySize[i],
                                        photo: PhotoArray().imgBeauty
                                    )
                                }
                            }
                        }
                        .onAppear {
                            // 最初に表示するViewのIDを指定して中央にスクロール
                            proxy.scrollTo(1, anchor: .center)
                        }
                    }
                    .offset(y: 12)
                }
            }
        }
        .onAppear() {
            editor.uiImage += [editor.uiImage[editor.uiImageNode]]
            editor.uiImageNode += 1
        }
    }
}
