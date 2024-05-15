//
//  PhotoView.swift
//  luminous
//
//  Created by kureha8827 on 2024/03/25.
//

import SwiftUI

struct PhotoView: View {
    @EnvironmentObject var cam: BaseCamView  // 初期状態は背面カメラ
    @EnvironmentObject var viewSwitcher: ViewSwitcher
    @State private var isEditing: Double = 0.0
    @State private var isShowFilterView: Bool = false
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                Image(uiImage: cam.uiImage)
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 16 / 9)
                    .padding(.top, 10)
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
                            viewSwitcher.value = 20
                        },
                        label: {
                            ZStack {
                                Circle()
                                    .frame(width: 64)
                                    .foregroundStyle(.purple2)
                                Circle()
                                    .frame(width: 58)
                                    .foregroundStyle(.white)
                            }
                        }
                    )
                    .buttonStyle(OpacityButtonStyle())

                    Spacer()

                    // 加工ボタン
                    ZStack {
                        // 最初のボタン
                        Button(
                            action: {
                                isEditing = (isEditing == 0 ? 1.0 : 0.0)
                            },
                            label: {
                                ZStack {
                                    Circle()
                                        .fill(.white)
                                        .shadow(radius: 3, x: 3, y: 3)
                                        .frame(width: 52)
                                    Circle()
                                        .fill(isEditing == 1 ? .white : .purple2)
                                        .frame(width: 48)
                                    Image(systemName: "plus")
                                        .font(.system(size: 24))
                                        .foregroundStyle(isEditing == 1 ? .purple2 : .white)
                                        .rotationEffect(.degrees(isEditing * 315))
                                }
                            }
                        )
                        .buttonStyle(OpacityButtonStyle())
                        .zIndex(3)

                        // フィルタボタン
                        Button(
                            action: {
                                isShowFilterView = true
                                let _ = print("\n\n\n\n\n\n\n\n\n\n\ninButton\n\(isShowFilterView)\n\n\n\n\n\n\n\n\n\n\n")
                            },
                            label: {
                                ZStack {
                                    Circle()
                                        .fill(.white)
                                        .shadow(radius: 4, x: 4, y: 4)
                                        .frame(width: 52)
                                    Circle()
                                        .fill(.purple2)
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
                                        .shadow(radius: 4, x: 4, y: 4)
                                        .frame(width: 52)
                                    Circle()
                                        .fill(.purple2)
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

                    Spacer()
                }
                .offset(y: 335)
                .sheet(isPresented: $isShowFilterView) {
                    let _ = print("\n\n\n\n\n\n\n\n\n\n\n\(isShowFilterView)\n\n\n\n\n\n\n\n\n\n\n")
                    FilterView()
                        .presentationDetents([.height(200)])
                }
            }
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
                            Label("", systemImage: "arrow.triangle.2.circlepath")
                        }
                    )
                    .tint(.black.opacity(0.7))
//                    .padding(.bottom, 5)
                }
            }
            .onAppear() {
                cam.captureSession()
            }
        }
    }
}
