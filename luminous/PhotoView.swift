//
//  PhotoView.swift
//  luminous
//
//  Created by kureha8827 on 2024/03/25.
//

import SwiftUI

struct PhotoView: View {
    @EnvironmentObject var cam: BaseCamView  // 初期状態は背面カメラ
    @EnvironmentObject var vs: ViewSwitcher
    @State private var isEditing: Double = 0.0
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                Image(uiImage: cam.uiImage)
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width,
                           height: UIScreen.main.bounds.width * 16 / 9)
                HStack {
                    Spacer()

                    // UIを整えるための空のパーツ
                    Circle()
                        .frame(width: 64)
                        .opacity(0)

                    Spacer()

                    // シャッターボタン
                    Button(
                        action: {
                            cam.canUse = false
                            cam.session.stopRunning()
                            vs.value = 20
                        },
                        label: {
                            ZStack {
                                Circle()
                                    .frame(width: 64)
                                    .foregroundStyle(.lightPurple)
                                Circle()
                                    .frame(width: 58)
                                    .foregroundStyle(.white)
                            }
                        }
                    )
                    .buttonStyle(OpacityButtonStyle())
                    .offset(y: vs.isShowFilterView * -96)

                    Spacer()

                    // 加工ボタン
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
                                        .frame(width: 52)
                                    if (isEditing == 1) {
                                        Circle()
                                            .fill(.white)
                                            .frame(width: 48)
                                    } else {
                                        Circle()
                                            .fill(.lightPurple)
                                            .frame(width: 48)
                                    }
                                    Image(systemName: "plus")
                                        .font(.system(size: 24))
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
                                vs.isShowFilterView = 1
                                isEditing = 0
                            },
                            label: {
                                ZStack {
                                    Circle()
                                        .fill(.white)
                                        .shadow(color: .black.opacity(0.1), radius: 1, y: 4)
                                        .frame(width: 52)
                                    Circle()
                                        .fill(.lightPurple)
                                        .frame(width: 48)
                                    Image(systemName: "camera.filters")
                                        .font(.system(size: 24))
                                        .foregroundStyle(.white)
                                        .rotationEffect(.degrees(isEditing * 135 - 135))
                                }
                            }
                        )
                        .offset(y: isEditing * -64)
                        .zIndex(2)

                        // TODO: 2つめのボタン
                        Button(
                            action: {

                            },
                            label: {
                                ZStack {
                                    Circle()
                                        .fill(.white)
                                        .shadow(color: .black.opacity(0.1), radius: 1, y: 4)
                                        .frame(width: 52)
                                    Circle()
                                        .fill(.lightPurple)
                                        .frame(width: 48)
                                    Image(systemName: "face.smiling")
                                        .font(.system(size: 24))
                                        .foregroundStyle(.white)
                                        .rotationEffect(.degrees(isEditing * 135 - 135))
                                }
                            }
                        )
                        .offset(y: isEditing * -128)
                        .zIndex(1)
                    }
                    .frame(width: 64)
                    .animation(
                        .easeOut(duration: 0.2),
                        value: isEditing
                    )
                    .opacity(1 - vs.isShowFilterView)

                    Spacer()
                }
                .offset(y: 336)
            }
            .animation(
                .easeOut(duration: 0.2),
                value: vs.isShowFilterView
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(
                        action: {
                            DispatchQueue.main.async {
                                cam.isCameraBack.toggle()
                                cam.changeCam()
                            }
                        },
                        label: {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 16))
                        }
                    )
                    .tint(.black.opacity(0.7))
                    .frame(height: 20)
                    .padding(.bottom, 0)
                }

            }
            .onAppear() {
                cam.captureSession()
            }
        }
    }
}
