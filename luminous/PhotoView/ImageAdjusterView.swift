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
    @State private var sliderValue: Float = 0
    @State private var sliderValueStr: String = ""
    @State private var isLongPress: Bool = false
    @FocusState private var isEditing: Field?
    var isPhotoView: Bool

    enum Field: Hashable {
        case size
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 0) {
                    // 上のライン
                    Rectangle()
                        .foregroundStyle(.white)
                        .frame(width: geometry.size.width, height: 2)
                        .offset(y: geometry.frame(in: .local).minY)

                    // 閉じるボタン
                    Button(action: {
                        vs.isShowImageAdjusterV = 0
                        isLongPress = false
                        isEditing = nil
                    }, label: {
                        Image(systemName: "multiply")
                            .font(.system(size: 24))
                            .tint(.gray191)
                    })
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 10)
                    .padding(.top, 6)
                    .padding(.bottom, 0)
                    .animation(
                        .easeOut(duration: 0.2),
                        value: vs.isShowImageAdjusterV
                    )

                    HStack(spacing: 0) {
                        Button(action: {    // originalフィルタ
                            DispatchQueue.global().async {
                                cam.currentAdjuster = 0
                                cam.adjusterSize = Array(repeating: Float(0), count: ConstStruct.adjusterNum)
                            }
                        }, label: {
                            ImageItemView(type: .adjuster, item: 0, value: cam.adjusterSize[0], photo: PhotoArray().imgAdjuster)
                        })

                        Rectangle()
                            .frame(width: 1, height: 48)
                            .padding(.leading, 6)
                            .foregroundStyle(.white)
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
                                                item: i,
                                                value: cam.adjusterSize[i],
                                                photo: PhotoArray().imgAdjuster
                                            )
                                        })
                                        .simultaneousGesture(
                                            LongPressGesture(minimumDuration: 0.4)
                                                .onChanged() { _ in
                                                    print("onChanged")
                                                }
                                                .onEnded { _ in
                                                    print("onEnded")
                                                    // 長押し時の動作
                                                    if cam.currentAdjuster == i {
                                                        isLongPress = true
                                                        isEditing = .size
                                                    }
                                                }
                                        )
                                        .simultaneousGesture(
                                            TapGesture()
                                                .onEnded { _ in
                                                    if cam.currentAdjuster == i {
                                                        sliderValue = 0
                                                    } else {
                                                        DispatchQueue.global().async {
                                                            cam.currentAdjuster = i
                                                            sliderValue = cam.adjusterSize[cam.currentAdjuster]
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
                                        if (cam.currentAdjuster == i) && isLongPress {
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
            cam.adjusterSize[cam.currentAdjuster] = sliderValue
        }
        .onTapGesture {
            if isEditing != nil {
                isEditing = nil
            }
        }
    }
}
