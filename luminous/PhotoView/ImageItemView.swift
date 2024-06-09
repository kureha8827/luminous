//
//  ImageItemView.swift
//  luminous
//
//  Created by kureha8827 on 2024/05/21.
//

import SwiftUI

struct ImageItemView: View {
    @EnvironmentObject var cam: BaseCamera
    var type: ItemType
    var item: Int       // どのフィルタを選択しているかを取得
    var value: Float    // フィルタサイズ
    var photo: [String]

    enum ItemType: String {
        case filter
        case adjuster
    }

    // TODO: フィルタ名を入力する

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                if type == .filter {
                    if item == cam.currentFilter {
                        Circle()
                            .stroke(.white, lineWidth: 1)
                            .frame(width: 60, height: 60)
                    }
                } else if type == .adjuster {
                    if item == cam.currentAdjuster {
                        Circle()
                            .stroke(.white, lineWidth: 1)
                            .frame(width: 60, height: 60)
                    }
                }

                if value >= 1 || value <= -1 {
                    Image(photo[item])
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                        .frame(width: 56, height: 56)
                        .blur(radius: 1)
                    Text("\(String(format: "%.0f", value))")
                        .foregroundStyle(.gray63)
                        .font(.system(size: 30))
                        .fontWeight(.thin)
                } else {
                    Image(photo[item])
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                        .frame(width: 56, height: 56)
                }

            }
            Text("\(photo[item])")
                .foregroundStyle(.gray63)
                .font(.system(size: 12))
                .fontWeight(.thin)
        }
        .frame(width: 64)
    }
}
