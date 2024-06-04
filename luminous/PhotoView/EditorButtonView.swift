//
//  EditorButtonView.swift
//  luminous
//
//  Created by kureha8827 on 2024/05/22.
//

import SwiftUI

struct EditorButtonView: View {
    @State private var isEditing: Double = 0.0
    @EnvironmentObject var vs: ViewSwitcher
    var body: some View {
        ZStack {
            // 最初のボタン
            Button(
                action: {
                    isEditing = (isEditing == 0 ? 1 : 0)    // isEditingが0なら1, 1なら0にする
                },
                label: {
                    ZStack {
                        Circle()
                            .fill(.white)
                            .shadow(color: .black.opacity(0.1), radius: 1, y: 4)
                            .frame(width: 64)
                        if (isEditing == 1) {
                            Circle()
                                .fill(.white)
                                .frame(width: 58)
                        } else {
                            Circle()
                                .fill(.lightPurple)
                                .frame(width: 58)
                        }
                        Image(systemName: "plus")
                            .font(.system(size: 30))
                            .foregroundStyle(isEditing == 1 ? .lightPurple : .white)
                            .rotationEffect(.degrees(isEditing * 315))
                    }
                }
            )
            .buttonStyle(OpacityButtonStyle())
            .zIndex(3)

            // フィルタボタン
            Button(
                action: {
                    vs.isShowImageFilterV = 1
                    isEditing = 0
                },
                label: {
                    ZStack {
                        Circle()
                            .fill(.lightPurple)
                            .frame(width: 64)
                            .shadow(color: .black.opacity(0.1), radius: 1, y: 4)
                        VStack {
                            Image(systemName: "camera.filters")
                                .font(.system(size: 30))
                            Text("フィルタ")
                                .font(.system(size: 10))
                                .fontWeight(.bold)
                        }
                        .rotationEffect(.degrees(isEditing * 135 - 135))
                        .foregroundStyle(.white)
                    }
                }
            )
            .rotationEffect(.degrees(round(-90.0*powl(Double(UIDevice.current.orientation.rawValue)-3.5+1.0/(4.0*Double(UIDevice.current.orientation.rawValue)-14.0), -11))))
            .offset(y: isEditing * -76)
            .zIndex(2)

            // 調整ボタン
            Button(
                action: {
                    vs.isShowImageAdjusterV = 1
                    isEditing = 0
                },
                label: {
                    ZStack {
                        Circle()
                            .fill(.lightPurple)
                            .frame(width: 64)
                            .shadow(color: .black.opacity(0.1), radius: 1, y: 4)
                        VStack {
                            Image(systemName: "circle.lefthalf.filled.inverse")
                                .font(.system(size: 30))
                            Text("調整")
                                .font(.system(size: 10))
                                .fontWeight(.bold)
                        }
                        .rotationEffect(.degrees(isEditing * 135 - 135))
                        .foregroundStyle(.white)
                    }
                }
            )
            .rotationEffect(.degrees(round(-90.0*powl(Double(UIDevice.current.orientation.rawValue)-3.5+1.0/(4.0*Double(UIDevice.current.orientation.rawValue)-14.0), -11))))
            .offset(y: isEditing * -152)
            .zIndex(1)

            // TODO: 3つめのボタン
            Button(
                action: {

                },
                label: {
                    ZStack {
                        Circle()
                            .fill(.lightPurple)
                            .frame(width: 64)
                            .shadow(color: .black.opacity(0.1), radius: 1, y: 4)
                        VStack {
                            Image(systemName: "face.smiling")
                                .font(.system(size: 30))
                            Text("おかお")
                                .font(.system(size: 10))
                                .fontWeight(.bold)
                        }
                        .rotationEffect(.degrees(isEditing * 135 - 135))
                        .foregroundStyle(.white)
                    }
                }
            )
            .rotationEffect(.degrees(round(-90.0*powl(Double(UIDevice.current.orientation.rawValue)-3.5+1.0/(4.0*Double(UIDevice.current.orientation.rawValue)-14.0), -11))))
            .offset(y: isEditing * -228)
            .zIndex(1)
        }
        .frame(width: 76)
        .animation(
            .easeOut(duration: 0.2),
            value: isEditing
        )
        .opacity(vs.isShowImageFilterV == 0 && vs.isShowImageAdjusterV == 0 ? 1 : 0)
    }
}
