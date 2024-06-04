//
//  FilterView.swift
//  luminous
//
//  Created by kureha8827 on 2024/05/15.
//

import SwiftUI

struct ImageFilterView: View {
    @EnvironmentObject var vs: ViewSwitcher
    @EnvironmentObject var cam: BaseCamView
    @StateObject var imgft = ImageFilter()
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
                        vs.isShowImageFilterV = 0
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
                        value: vs.isShowImageFilterV
                    )

                    HStack(spacing: 0) {
                        Button(action: {    // originalフィルタ
                            DispatchQueue.global().async {
                                cam.currentFilter = 0
                            }
                        }, label: {
                            ImageItemView(type: .filter ,item: 0, value: imgft.filterSize[0], photo: PhotoArray().imgFilter)
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
                                ForEach(1..<cam.imgFilterNum, id: \.self) { i in   // 1からの番号を渡す(0はoriginal)
                                    Button(action: {
                                        DispatchQueue.global().async {
                                            cam.currentFilter = i
                                            sliderValue = imgft.filterSize[cam.currentFilter]
                                        }
                                    }, label: {
                                        ImageItemView(type: .filter ,item: i, value: imgft.filterSize[i], photo: PhotoArray().imgFilter)
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
                if cam.currentFilter >= 1 { // original選択時はスライダ非表示
                    VStack{
                        PositiveSlider(value: $sliderValue, width: 220)
                            .frame(width: 220)
                            .rotationEffect(.degrees(-90))
                            .offset(x: geometry.frame(in: .local).midX - 18, y: -180)
                    }
                }
            }
        }
        .onChange(of: sliderValue) {
            imgft.filterSize[cam.currentFilter] = sliderValue
        }
    }
}
