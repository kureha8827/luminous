//
//  ImageAdjuster.swift
//  luminous
//
//  Created by kureha8827 on 2024/05/21.
//

import SwiftUI

struct ImageAdjusterView: View {
    @EnvironmentObject var vs: ViewSwitcher
    @EnvironmentObject var cam: BaseCamView
    @State private var sliderValue: Float = 0

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
                            }
                        }, label: {
                            ImageItemView(type: .adjuster ,item: 0, value: cam.adjusterSize[0], photo: PhotoArray().imgAdjuster)
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
                                ForEach(1..<cam.imgAdjusterNum, id: \.self) { i in   // 1からの番号を渡す(0はoriginal)
                                    Button(action: {
                                        // 選択状態で更にボタンを押すとスライダを0に戻す
                                        if cam.currentAdjuster == i {
                                            sliderValue = 0
                                        } else {
                                            DispatchQueue.global().async {
                                                cam.currentAdjuster = i
                                                sliderValue = cam.adjusterSize[cam.currentAdjuster]
                                            }
                                        }
                                    }, label: {
                                        ImageItemView(type: .adjuster ,item: i, value: cam.adjusterSize[i], photo: PhotoArray().imgAdjuster)
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
                }
                if cam.currentAdjuster >= 5 {
                    VStack{
                        PositiveSlider(value: $sliderValue, width: 220)
                            .frame(width: 220)
                            .rotationEffect(.degrees(-90))
                            .offset(x: geometry.frame(in: .local).midX - 18, y: -180)
                    }
                } else if cam.currentAdjuster >= 1 {
                    NegativeSlider(value: $sliderValue, width: 220)
                        .frame(width: 220)
                        .rotationEffect(.degrees(-90))
                        .offset(x: geometry.frame(in: .local).midX - 18, y: -180)
                }
            }
        }
        .onChange(of: sliderValue) {
            cam.adjusterSize[cam.currentAdjuster] = sliderValue
        }
    }
}
