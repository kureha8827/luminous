//
//  ImageItemView.swift
//  luminous
//
//  Created by kureha8827 on 2024/05/21.
//

import SwiftUI

struct ImageItemView: View {
    @EnvironmentObject var cam: BaseCamera
    @EnvironmentObject var editor: Editor
    var type: ItemType
    var viewType: ViewType
    var item: Int       // どのフィルタを選択しているかを取得
    var value: Float    // フィルタサイズ
    var photo: [String]

    enum ItemType: String {
        case filter
        case adjuster
        case beauty
    }

    enum ViewType: String {
        case photo
        case editor
    }

    // TODO: フィルタ名を入力する

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                if type == .filter {
                    if item == cam.currentFilter && viewType == .photo {
                        Circle()
                            .stroke(.white, lineWidth: 1)
                            .frame(width: 60, height: 60)
                    }
                    if item == editor.currentFilter && viewType == .editor {
                        Circle()
                            .stroke(.gray63, lineWidth: 1)
                            .frame(width: 60, height: 60)
                    }
                } else if type == .adjuster {
                    if item == cam.currentAdjuster && viewType == .photo {
                        Circle()
                            .stroke(.white, lineWidth: 1)
                            .frame(width: 60, height: 60)
                    }
                    if item == editor.currentAdjuster && viewType == .editor {
                        Circle()
                            .stroke(.gray63, lineWidth: 1)
                            .frame(width: 60, height: 60)
                    }
                }

                if abs(value) >= 1 {
                    if type == .filter {
                        Image(photo[item])
                            .resizable()
                            .mask(Circle())
                            .frame(width: 54, height: 54)
                            .blur(radius: 1)
                    } else {
                        Image(photo[item])
                            .resizable()
                            .renderingMode(.template)
                            .foregroundStyle(viewType == .photo ? .white : .gray31)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 40, height: 40)
                            .blur(radius: 1)
                    }
                    Text("\(String(format: "%.0f", value))")
                        .foregroundStyle(.gray63)
                        .font(.system(size: 28))
                        .fontWeight(.thin)
                } else {
                    if type == .filter {
                        if item != 0 {
                            Image(photo[item])
                                .resizable()
                                .mask(Circle())
                                .frame(width: 54, height: 54)
                        } else {
                            Image(photo[item])
                                .resizable()
                                .renderingMode(.template)
                                .foregroundStyle(viewType == .photo ? .white : .gray31)
                                .frame(width: 54, height: 54)
                        }
                    } else {
                        Image(photo[item])
                            .resizable()
                            .renderingMode(.template)
                            .foregroundStyle(viewType == .photo ? .white : .gray31)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 40, height: 40)
                    }
                }
            }
            .frame(width: 62, height: 62)

            FitText("\(photo[item])")
                .foregroundStyle(.gray63)
                .font(.system(size: 12))
                .fontWeight(.thin)
                .frame(height: 16)
        }
        .frame(width: 72, height: 88, alignment: .top)
    }
}
