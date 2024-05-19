//
//  FilterView.swift
//  luminous
//
//  Created by kureha8827 on 2024/05/15.
//

import SwiftUI

struct FilterView: View {
    @EnvironmentObject var vs: ViewSwitcher
    @EnvironmentObject var cam: BaseCamView
    @StateObject var ft = Filter()
    @State private var test: [Double] = Array(repeating: 1.0, count: 10)

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
                        vs.isShowFilterView = 0
                        cam.currentFilter = nil     // フィルタの選択状態をクリア
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
                        value: vs.isShowFilterView
                    )

                    HStack(spacing: 0) {
                        Button(action: {    // originalフィルタ
                            DispatchQueue.global().async {
                                cam.currentFilter = 0
                            }
                        }, label: {
                            FilterIconView(item: 0)
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
                                ForEach(1..<cam.filterNum, id: \.self) { i in   // 1からの番号を渡す(0はoriginal)
                                    Button(action: {
                                        DispatchQueue.global().async {
                                            cam.currentFilter = i
                                        }
                                    }, label: {
                                        FilterIconView(item: i)
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
                if let index = cam.currentFilter {
                    VStack{
                        Text("\(index)")
                        Text("\(test[index])")
                        MainSlider(value: $test[index], width: 220)
                            .frame(width: 220)
                            .rotationEffect(.degrees(-90))
                            .offset(x: geometry.frame(in: .local).midX - 18, y: -180)

                        // ↓の処理なら完璧(MainSliderに問題あり)
//                        Slider(value: $ft.filterSize[index])
//                            .frame(width: 220)
//                            .rotationEffect(.degrees(-90))
//                            .offset(x: geometry.frame(in: .local).midX - 18, y: -180)
                    }
                }
            }
        }
    }
}

struct FilterIconView: View {
    @EnvironmentObject var cam: BaseCamView
    var item: Int

    // TODO: フィルタ名を入力する
    let photo = [
        "original",
        "150x150",
        "150x150",
        "150x150",
        "150x150",
        "150x150",
        "150x150",
        "150x150",
        "150x150",
        "150x150"
    ]

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                if item == cam.currentFilter {
                    Circle()
                        .stroke(.white, lineWidth: 1)
                        .frame(width: 60, height: 60)
                }
                Image(photo[item])
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
                    .frame(width: 56, height: 56)
            }
            Text("\(photo[item])")
                .foregroundStyle(.gray63)
                .font(.system(size: 12))
                .fontWeight(.thin)
        }
        .frame(width: 64)
    }
}


