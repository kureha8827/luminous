//
//  EditorButtonView.swift
//  luminous
//
//  Created by kureha8827 on 2024/05/22.
//

import SwiftUI

struct EditorButtonView: View {
    @EnvironmentObject var vs: ViewSwitcher
    @EnvironmentObject var photoStatus: PhotoObservableClass
    var body: some View {
        ZStack {
            // 最初のボタン
            Button(
                action: {
                    photoStatus.isEditing = (photoStatus.isEditing == 0 ? 1 : 0)    // photoStatus.isEditingが0なら1, 1なら0にする
                },
                label: {
                    ZStack {
                        Circle()
                            .fill(.white)
                            .shadow(color: .black.opacity(0.1), radius: 1, y: 4)
                            .frame(width: 64)
                        if (photoStatus.isEditing == 1) {
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
                            .foregroundStyle(photoStatus.isEditing == 1 ? .lightPurple : .white)
                            .rotationEffect(.degrees(photoStatus.isEditing * 315))
                    }
                }
            )
            .buttonStyle(OpacityButtonStyle())
            .zIndex(3)

            // フィルタボタン
            Button(
                action: {
                    photoStatus.isShowFilter = 1
                    photoStatus.isEditing = 0
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
                        .rotationEffect(.degrees(photoStatus.isEditing * 135 - 135))
                        .foregroundStyle(.white)
                    }
                }
            )
            .rotationEffect(.degrees(round(-90.0*powl(Double(UIDevice.current.orientation.rawValue)-3.5+1.0/(4.0*Double(UIDevice.current.orientation.rawValue)-14.0), -11))))
            .offset(y: photoStatus.isEditing * -76)
            .zIndex(2)

            // 調整ボタン
            Button(
                action: {
                    photoStatus.isShowAdjuster = 1
                    photoStatus.isEditing = 0
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
                        .rotationEffect(.degrees(photoStatus.isEditing * 135 - 135))
                        .foregroundStyle(.white)
                    }
                }
            )
            .rotationEffect(.degrees(round(-90.0*powl(Double(UIDevice.current.orientation.rawValue)-3.5+1.0/(4.0*Double(UIDevice.current.orientation.rawValue)-14.0), -11))))
            .offset(y: photoStatus.isEditing * -152)
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
                        .rotationEffect(.degrees(photoStatus.isEditing * 135 - 135))
                        .foregroundStyle(.white)
                    }
                }
            )
            .rotationEffect(.degrees(round(-90.0*powl(Double(UIDevice.current.orientation.rawValue)-3.5+1.0/(4.0*Double(UIDevice.current.orientation.rawValue)-14.0), -11))))
            .offset(y: photoStatus.isEditing * -228)
            .zIndex(1)
        }
        .frame(width: 76)
        .onChange(of: photoStatus.isSwipe) {
            if photoStatus.isSwipe {
                photoStatus.isEditing = 0
            }
        }
        .animation(
            .easeOut(duration: 0.2),
            value: photoStatus.isEditing
        )
        .opacity(photoStatus.isShowFilter == 0 && photoStatus.isShowAdjuster == 0 ? 1 : 0)
    }
}
