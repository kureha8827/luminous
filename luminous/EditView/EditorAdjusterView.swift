//
//  EditorAdjusterView.swift
//  luminous
//
//  Created by kureha8827 on 2024/07/04.
//

import SwiftUI

struct EditorAdjusterView: View {
    @EnvironmentObject var editor: Editor
    @State private var sliderValue: Float = 0
    @State private var sliderValueStr: String = ""
    @State private var isLongPress: Bool = false
    @FocusState private var isEditing: Field?

    enum Field: Hashable {
        case size
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                HStack(spacing: 0) {
                    Button(action: {    // originalフィルタ
                        Task { @MainActor in
                            editor.currentAdjuster = 0
                            editor.adjusterSize = Array(repeating: Float(0), count: ConstStruct.adjusterNum)
                        }
                    }, label: {
                        ImageItemView(
                            type: .adjuster,
                            viewType: .editor,
                            item: 0,
                            value: editor.adjusterSize[0],
                            photo: PhotoArray().imgAdjuster
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
                            // FIXME: フィルタ機能を作るために一時的に調整タブをすべて解放
                            // ForEach(1..<(isPhotoView ? 5 : ConstStruct.adjusterNum), id: \.self) {
                            ForEach(1..<ConstStruct.adjusterNum, id: \.self) { i in   // 1からの番号を渡す(0はoriginal)
                                ZStack {
                                    Button(action: {
                                    }, label: {
                                        ImageItemView(
                                            type: .adjuster,
                                            viewType: .editor,
                                            item: i,
                                            value: editor.adjusterSize[i],
                                            photo: PhotoArray().imgAdjuster
                                        )
                                    })
                                    .simultaneousGesture(
                                        LongPressGesture(minimumDuration: 0.4)
                                            .onChanged() { _ in
                                            }
                                            .onEnded { _ in
                                                // 長押し時の動作
                                                if editor.currentAdjuster == i {
                                                    isLongPress = true
                                                    isEditing = .size
                                                }
                                            }
                                    )
                                    .simultaneousGesture(
                                        TapGesture()
                                            .onEnded { _ in
                                                if editor.currentAdjuster == i {
                                                    sliderValue = 0
                                                } else {
                                                    Task { @MainActor in
                                                        editor.currentAdjuster = i
                                                        sliderValue = editor.adjusterSize[editor.currentAdjuster]
                                                    }
                                                }
                                            }
                                    )
                                    .highPriorityGesture(
                                        DragGesture()
                                            .onChanged { value in
                                                // スクロール中は長押しを無効化する
                                                //                                                isLongPress = false
                                            }
                                    )
                                    if (editor.currentAdjuster == i) && isLongPress {
                                        TextField("", text: $sliderValueStr)
                                            .focused($isEditing, equals: .size)
                                            .foregroundStyle(.gray63)
                                            .font(.system(size: 28))
                                            .fontWeight(.thin)
                                            .opacity(0)
                                    }
                                }
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
                
                Group {
                    if editor.currentAdjuster >= 9 {
                        PositiveSlider(value: $sliderValue, width: 220)
                        
                    } else if editor.currentAdjuster >= 1 {
                        NegativeSlider(value: $sliderValue, width: 220)
                    }
                }
                .frame(width: 220)
                .rotationEffect(.degrees(-90))
                .offset(x: geometry.frame(in: .local).midX - 18, y: -180)
            }
        }
        .onChange(of: sliderValueStr) {
            if let numeric = Float(sliderValueStr) {
                sliderValue = numeric
            } else if sliderValueStr == "-" {
            }  else if sliderValueStr == "" {
                sliderValue = 0
            } else {
                sliderValueStr = "0"
            }
        }
        .onChange(of: sliderValue) {
            editor.adjusterSize[editor.currentAdjuster] = sliderValue
        }
        .onTapGesture {
            if isEditing != nil {
                isEditing = nil
            }
        }
    }
}
