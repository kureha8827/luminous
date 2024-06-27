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
    @EnvironmentObject var photoStatus: PhotoObservableClass

    @State private var lastMagnify: Float = 0

    var body: some View {
        let magnificationGesture = MagnificationGesture()
            .onChanged { v in
                let value = Float(log(v)) * 4
                let delta: Float = (value - lastMagnify) // ユーザビリティ向上の為の計算
                lastMagnify = value

                if Float(cam.minFactor) < cam.linearZoomFactor + delta && cam.linearZoomFactor + delta < Float(cam.maxFactor) {
                    cam.linearZoomFactor += delta
                }
            }
            .onEnded { _ in
                lastMagnify = 0
            }

        let swipeGesture = DragGesture()
            .onEnded { gesture in
                photoStatus.isSwipe = gesture.translation.height < 0 ? true : false
                photoStatus.isEditing = 0.0
                photoStatus.isShowAdjuster = 0.0
                photoStatus.isShowFilter = 0.0
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
                    case 1:
                        Image(uiImage: cam.uiImage)
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width,
                                   height: UIScreen.main.bounds.width * 4 / 3)
                            .offset(y: -6)
                    case 2:
                        Image(uiImage: cam.uiImage)
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width,
                                   height: UIScreen.main.bounds.width)
                            .offset(y: -40)
                    default: EmptyView()
                    }
                }
                .blur(radius:
                        cam.isShowCamera ? 0 : 20)
                .gesture(SimultaneousGesture(
                    magnificationGesture,
                    swipeGesture
                ))
                .onTapGesture {
                    photoStatus.isEditing = 0.0
                    photoStatus.isShowAdjuster = 0.0
                    photoStatus.isShowFilter = 0.0
                    photoStatus.isSwipe = false
                }

                // タイマー選択中 && カメラが使用可能 && タイマー動作中
                if (cam.timer?.isValid ?? false) {  // cam.timer?.isValid == nilのときfalseを返す
                    if (cam.optionSelect[3] != 0 && !cam.canUse) {
                        Text("\(cam.time > 0 ? Int(ceil(cam.time)) : 1)")
                            .font(.system(size: CGFloat(14400*pow(cam.time - floor(cam.time) - 0.5, 5) + 250) > 0 ? CGFloat(14400*pow(cam.time - floor(cam.time) - 0.5, 5) + 250) : 1))             // (cam.time - floor(cam.time)) max, mid, min = 700, 250, 1        4000*pow(cam.time - floor(cam.time) - 0.5, 3) + 501
                            .opacity(CGFloat(-6*pow(cam.time - floor(cam.time) - 0.5, 4) + 1) > 0 ? CGFloat(-6*pow(cam.time - floor(cam.time) - 0.5, 4) + 1) : 0)
                            .foregroundStyle(.white)
                    }
                }

                OptionView()
                    .offset(y: photoStatus.isSwipe ? 240 : 300)
                    .opacity(photoStatus.isSwipe ? 1 : 0)
                    .animation(
                        .easeOut(duration: 0.2),
                        value: photoStatus.isSwipe
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
                                cam.takePhoto(vs)
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
                    .offset(y: photoStatus.isShowFilter == 0 && photoStatus.isShowAdjuster == 0 ? 0 : -104)

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
                    // カメラ切り替え
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
            .onChange(of: photoStatus.isEditing) {
                if (photoStatus.isEditing == 1) {
                    photoStatus.isSwipe = false
                }
            }
            .animation(
                .easeOut(duration: 0.2),
                value: photoStatus.isShowFilter
            )
            .animation(
                .easeOut(duration: 0.2),
                value: photoStatus.isShowAdjuster
            )
            .animation(
                .easeOut(duration: 0.2),
                value: UIDevice.current.orientation
            )
        }
    }
}
