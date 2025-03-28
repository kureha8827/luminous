//
//  ImageAdjuster.swift
//  luminous
//
//  Created by kureha8827 on 2024/05/21.
//

import SwiftUI

struct ImageAdjusterView: View {
    @EnvironmentObject var vs: ViewSwitcher
    @EnvironmentObject var cam: BaseCamera
    @EnvironmentObject var photoStatus: PhotoObservableClass
    @State private var sliderValue: Int = 0
    @State private var sliderValueStr: String = ""
    @State private var isLongPress: Bool = false
    @FocusState private var isEditing: Field?
    var is16x9: Bool

    enum Field: Hashable {
        case size
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 0) {
                    // 上のライン
                    if is16x9 {
                        Rectangle()
                            .foregroundStyle(.white)
                            .frame(width: geometry.size.width, height: 2)
                            .offset(y: geometry.frame(in: .local).minY)
                    }

                    // 閉じるボタン
                    Button(action: {
                        photoStatus.isShowAdjuster = 0
                        isLongPress = false
                        isEditing = nil
                    }, label: {
                        Image(systemName: "multiply")
                            .font(.system(size: 24))
                            .tint(.gray191)
                    })
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 10)
                    .padding(.top, is16x9 ? 6 : 12)
                    .padding(.bottom, 0)
                    .animation(
                        .easeOut(duration: 0.2),
                        value: photoStatus.isShowAdjuster
                    )

                    HStack(spacing: 0) {
                        Button(action: {    // originalフィルタ
                            Task { @MainActor in
                                cam.currentAdjuster = 0
                                cam.adjusterSize = Array(repeating: 0, count: ConstStruct.adjusterNum)
                            }
                        }, label: {
                            ImageItemView(
                                type: .adjuster,
                                viewType: .photo,
                                item: 0,
                                valueStr: String(cam.adjusterSize[0]),
                                photo: PhotoArray().imgAdjuster
                            )
                        })

                        // 縦線
                        Rectangle()
                            .frame(width: 1, height: 48)
                            .padding(.leading, 6)
                            .foregroundStyle(is16x9 ? .white : .gray63)
                            .offset(y: -12)

                        ScrollViewReader { proxy in
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    // 以下の警告に対応するために id: \.self を追加
                                    // Non-constant range: argument must be an integer literal
                                    // FIXME: フィルタ機能を作るために一時的に調整タブをすべて解放
                                    // ForEach(1..<(isCameraView ? 5 : ConstStruct.adjusterNum), id: \.self) {
                                    ForEach(1..<ConstStruct.adjusterNum, id: \.self) { i in   // 1からの番号を渡す(0はoriginal)
                                        ZStack {
                                            Button() {

                                            } label: {
                                                ImageItemView(
                                                    type: .adjuster,
                                                    viewType: .photo,
                                                    item: i,
                                                    valueStr: cam.currentAdjuster == i ? sliderValueStr : String(cam.adjusterSize[i]),
                                                    photo: PhotoArray().imgAdjuster
                                                )
                                            }
                                            .simultaneousGesture(
                                                LongPressGesture(minimumDuration: 0.4)
                                                    .onChanged() { _ in
                                                    }
                                                    .onEnded { _ in
                                                        // 長押し時の動作
                                                        cam.currentAdjuster = i
                                                        isLongPress = true
                                                        isEditing = .size
                                                        sliderValueStr = ""
                                                    }
                                            )
                                            .simultaneousGesture(
                                                TapGesture()
                                                    .onEnded { _ in
                                                        if cam.currentAdjuster == i {
                                                            sliderValue = 0
                                                        } else {
                                                            cam.currentAdjuster = i
                                                            sliderValue = cam.adjusterSize[cam.currentAdjuster]
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
                                            if isLongPress && cam.currentAdjuster == i {
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
                    }
                    .offset(y: 12)
                    .padding(.leading, 8)
                }

                Group {
                    if cam.currentAdjuster >= 9 {
                        PositiveSlider(value: $sliderValue, width: 220)

                    } else if cam.currentAdjuster >= 1 {
                        NegativeSlider(value: $sliderValue, width: 220)
                    }
                }
                .frame(width: 220)
                .rotationEffect(.degrees(-90))
                .offset(x: geometry.frame(in: .local).midX - 18, y: -180)

            }
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
            cam.adjusterSize[cam.currentAdjuster] = sliderValue
            sliderValueStr = sliderValue == 0 ? "" : String(sliderValue)
        }
        .onTapGesture {
            if isEditing != nil {
                isEditing = nil
            }
        }
    }
}
