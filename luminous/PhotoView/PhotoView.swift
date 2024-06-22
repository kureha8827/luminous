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
    @State private var lastMagnify: Float = 0
    @State private var isSwipe: Bool = false

    var body: some View {
        let magnificationGesture = MagnificationGesture()
            .onChanged { v in
                let value = Float(log(v)) * 4
                let delta: Float = (value - lastMagnify) // ユーザビリティ向上の為の計算
                lastMagnify = value

                print("v: \(Float(v)), value: \(value)")
                print("2: \(Float(delta))")
                print("3: \(Float(cam.linearZoomFactor))")
                if Float(cam.minFactor) < cam.linearZoomFactor + delta && cam.linearZoomFactor + delta < Float(cam.maxFactor) {
                    cam.linearZoomFactor += delta
                    print("zoom")
                }
            }
            .onEnded { _ in
                lastMagnify = 0
            }

        let swipeGesture = DragGesture()
            .onEnded { gesture in
                if gesture.translation.height < 0 {
                    isSwipe = true
                    print("isSwipe: true")
                } else {
                    isSwipe = false
                    print("isSwipe: false")
                }
            }

        NavigationStack {
            ZStack {
                VolumeButtonShutter()   // 音量ボタンで撮影を行う
                Color.white
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                Image(uiImage: cam.uiImage)
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width,
                           height: UIScreen.main.bounds.width * 16 / 9)
                    .gesture(SimultaneousGesture(
                        magnificationGesture,
                        swipeGesture
                    ))

                OptionView()
                    .offset(y: isSwipe ? 240 : 300)
                    .opacity(isSwipe ? 1 : 0)
                    .animation(
                        .easeOut(duration: 0.2),
                        value: isSwipe
                    )

                HStack {
                    Spacer()

                    // UIを整えるための空のパーツ
                    Circle()
                        .frame(width: 76)
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
