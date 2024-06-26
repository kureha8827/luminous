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
                isSwipe = gesture.translation.height < 0 ? true : false
            }

        NavigationStack {
            ZStack {
                VolumeButtonShutter()   // 音量ボタンで撮影を行う
                Color.white
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .gesture(
                        swipeGesture
                    )
                Group {
                    switch cam.optionSelect[1] {
                    case 0:
                        Image(uiImage: cam.uiImage)
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width,
                                   height: UIScreen.main.bounds.width * 16 / 9)
                            .gesture(SimultaneousGesture(
                                magnificationGesture,
                                swipeGesture
                            ))
                    case 1:
                        Image(uiImage: cam.uiImage)
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width,
                                   height: UIScreen.main.bounds.width * 4 / 3)
                            .offset(y: -6)
                            .gesture(SimultaneousGesture(
                                magnificationGesture,
                                swipeGesture
                            ))
                    case 2:
                        Image(uiImage: cam.uiImage)
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width,
                                   height: UIScreen.main.bounds.width)
                            .offset(y: -40)
                            .gesture(SimultaneousGesture(
                                magnificationGesture,
                                swipeGesture
                            ))
                    default: EmptyView()
                    }
                }
                .blur(radius:
                        cam.isShowCamera ? 0 : 20)

                if (cam.optionSelect[3] != 0 && !cam.canUse) {
                    Text("\(cam.time)")
                        .font(.system(size: CGFloat(300 + 1)))
                        .foregroundStyle(.white)
                        .frame(width: 300, height: 300, alignment: .center)
                }

                OptionView()
                    .offset(y: isSwipe ? 240 : 300)
                    .opacity(isSwipe ? 1 : 0)
                    .animation(
                        .easeOut(duration: 0.2),
                        value: isSwipe
                    )
                    .gesture(
                        swipeGesture
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
                            if cam.canUse {
                                cam.takePhoto()
                                if (cam.optionSelect[3] == 0) {
                                    if (cam.optionSelect[2] == 1) {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                                            vs.value = 20
                                        }
                                    } else {
                                        vs.value = 20
                                    }
                                } else if (cam.optionSelect[3] == 1) {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                                        if (cam.optionSelect[2] == 1) {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                                                vs.value = 20
                                            }
                                        } else {
                                            vs.value = 20
                                        }
                                    }
                                } else if (cam.optionSelect[3] == 2) {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 11) {
                                        if (cam.optionSelect[2] == 1) {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                                                vs.value = 20
                                            }
                                        } else {
                                            vs.value = 20
                                        }
                                    }
                                }
                            }
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
            .onAppear() {
                cam.captureSession()
            }
            .onChange(of: cam.time) {
                cam.timeDelta = 0
            }
            .animation(
                .easeOut(duration: 0.2),
                value: vs.isShowImageFilterV
            )
            .animation(
                .easeOut(duration: 0.2),
                value: vs.isShowImageAdjusterV
            )
            .animation(
                .easeOut(duration: 0.2),
                value: UIDevice.current.orientation
            )
            .animation(
                .easeOut(duration: 1),
                value: cam.timeDelta
            )
        }
    }
}
