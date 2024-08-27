//
//  EditorFaceView.swift
//  luminous
//
//  Created by kureha8827 on 2024/08/21.
//

import SwiftUI

struct EditorFaceView: View {
    @EnvironmentObject var editor: Editor
    @State private var sliderValue: Int = 0
    @State private var sliderValueStr: String = ""
    @State private var isLongPress: Bool = false
    @FocusState private var isEditing: Field?

    enum Field: Hashable {
        case size
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 32) {
                            ForEach(0..<BeautyFace.faceTab.count, id: \.self) { i in
                                Button() {
                                    editor.currentBeauty[1] = i
                                } label: {
                                    Text("\(Beauty.faceTab[i])")
                                        .foregroundStyle(editor.currentBeauty[1] == i ? .gray31 : .gray)
                                        .font(.system(size: 16))
                                        .fontWeight(.thin)
                                        .tracking(2)
                                }
                            }
                        }
                    }
                    .padding(.top, 12)
                    .padding(.leading, 8)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(0..<BeautyFace.faceTab[editor.currentBeauty[1]].count, id: \.self) { i in
                                ZStack {
                                    Button() {

                                    } label: {
                                        ImageItemView(
                                            type: .beauty,
                                            viewType: .editor,
                                            item: i,
                                            valueStr: editor.currentBeauty[2] == i ? sliderValueStr : String(editor.beautySize[0][editor.currentBeauty[1]][i]),
                                            photo: BeautyFace.faceTab[editor.currentBeauty[1]]
                                        )
                                    }
                                    .simultaneousGesture(
                                        LongPressGesture(minimumDuration: 0.4)
                                            .onChanged() { _ in
                                            }
                                            .onEnded { _ in
                                                // 長押し時の動作
                                                editor.currentBeauty[2] = i
                                                isLongPress = true
                                                isEditing = .size
                                                sliderValueStr = ""
                                            }
                                    )
                                    .simultaneousGesture(
                                        TapGesture()
                                            .onEnded { _ in
                                                if editor.currentBeauty[2] == i {
                                                    sliderValue = 0
                                                } else {
                                                    editor.currentBeauty[2] = i
                                                    sliderValue = editor.beautySize[0][editor.currentBeauty[1]][i]
                                                }
                                            }
                                    )
                                    .highPriorityGesture(
                                        DragGesture()
                                            .onChanged { value in

                                            }
                                    )
                                    if isLongPress && editor.currentBeauty[2] == i {
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
                    }
                    .padding(.leading, 8)
                    .padding(.bottom, 8)
                }
                .frame(alignment: .top)

                NegativeSlider(value: $sliderValue, width: 220)
                .frame(width: 220)
                .rotationEffect(.degrees(-90))
                .offset(x: geometry.frame(in: .local).midX - 18, y: -180)
            }
        }
        .onAppear() {
            print(#function)
            editor.uiImage += [editor.uiImage[editor.uiImageNode]]
            editor.uiImageNode += 1
        }
        .onChange(of: sliderValueStr) { // 長押し時に有効な値が渡されるかの確認
            if let numeric = Int(sliderValueStr) {
                sliderValue = numeric
            } else if sliderValueStr == "-" {
                sliderValue = 0
            }  else if sliderValueStr == "" {
                sliderValue = 0
            } else {
                sliderValueStr = ""
            }
        }
        .onChange(of: sliderValue) {
            editor.beautySize[0][editor.currentBeauty[1]][editor.currentBeauty[2]] = sliderValue
            sliderValueStr = sliderValue == 0 ? "" : String(sliderValue)
            editor.edit()
        }
        .onTapGesture {
            if isEditing != nil {
                isEditing = nil
            }
        }
    }
}
