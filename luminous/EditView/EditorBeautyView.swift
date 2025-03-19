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
                            ForEach(0..<Beauty.kinds.count, id: \.self) { i in   // 1からの番号を渡す(0はoriginal)
                                Button {
                                    editor.currentBeauty[0] = i
                                } label: {
                                    VStack(spacing: 12) {
                                        Image("\(PhotoArray().imgBeauty[i])")
                                            .resizable()
                                            .mask(Circle())
                                            .frame(width: 54, height: 54)

                                        FitText("\(PhotoArray().imgBeauty[i])")
                                            .foregroundStyle(.gray63)
                                            .font(.system(size: 12))
                                            .fontWeight(.thin)
                                            .frame(height: 16)
                                    }
                                    .frame(width: 72, height: 88, alignment: .top)
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
                .offset(y: editor.currentBeauty[0] == -1 ? 0 : 180)
                .opacity(editor.currentBeauty[0] == -1 ? 1 : 0)

                EditorFaceView()
                    .offset(y: editor.currentBeauty[0] == 0 ? 40 : 220)
                    .opacity(editor.currentBeauty[0] == 0 ? 1 : 0)
                // TODO: Editor...Viewを追加する

            }
        }
        .animation(
            .easeOut(duration: 0.2),
            value: editor.currentBeauty[0]
        )
    }
}
