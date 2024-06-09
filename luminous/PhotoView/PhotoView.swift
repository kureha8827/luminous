//
//  PhotoView.swift
//  luminous
//
//  Created by kureha8827 on 2024/03/25.
//

import SwiftUI

struct PhotoView: View {
    @EnvironmentObject var cam: BaseCamera  // 初期状態は背面カメラ
    @EnvironmentObject var vs: ViewSwitcher
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
                            cam.takePhoto()
                            vs.value = 20
                        },
                        label: {
                            ZStack {
                                Circle()
                                    .frame(width: 72)
                                    .foregroundStyle(.lightPurple)
                                Circle()
                                    .frame(width: 64)
                                    .foregroundStyle(.white)
                            }
                        }
                    )
                    .buttonStyle(OpacityButtonStyle())
                    .offset(y: vs.isShowImageFilterV == 0 && vs.isShowImageAdjusterV == 0 ? 0 : -104)

                    Spacer()

                    // 加工ボタン
                    EditorButtonView()

                    Spacer()
                }
                .offset(y: 320)
            }
            .animation(
                .easeOut(duration: 0.2),
                value: vs.isShowImageFilterV
            )
            .animation(
                .easeOut(duration: 0.2),
                value: vs.isShowImageAdjusterV
            )
            // ツールバー
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
                    .rotationEffect(.degrees(round(-90.0*powl(Double(UIDevice.current.orientation.rawValue)-3.5+1.0/(4.0*Double(UIDevice.current.orientation.rawValue)-14.0), -11))))
                    .tint(.black.opacity(0.7))
                    .frame(height: 20)
                    .padding(.bottom, 0)
                }

            }
            .animation(
                .easeOut(duration: 0.2),
                value: UIDevice.current.orientation
            )
            .onAppear() {
                cam.captureSession()
            }
        }
    }
}
