//
//  StartingView.swift
//  luminous
//
//  Created by kureha8827 on 2024/03/19.
//

import SwiftUI
import SpriteKit
import AVFoundation

struct BeginView: View {
    @EnvironmentObject var vs: ViewSwitcher
    @EnvironmentObject var cam: BaseCamera
    @Environment(\.scenePhase) private var scenePhase   // アプリの状態(起動中かバックグラウンドで動いているか等)の取得
    @State private var appearance = 1.0
    @State private var changeRate: Bool = false
    @State private var sceneChangeDuration = 0.6
    @State private var isShowAlert: Bool = false
    @State private var canAccessCam: Bool = false
    var body: some View {
        ZStack {
            Color.white
                .mask {
                    Rectangle()
                        .overlay() {
                            Circle()
                                .blendMode(.destinationOut)
                                .frame(width: changeRate ? 1000 : 0, height: changeRate ? 1000 : 0)
                        }
                        .compositingGroup()
                }
                .zIndex(2)
                .ignoresSafeArea()
            // TODO: ランダムで文字列を追加？
            TitleView(scale: 1)
                .offset(y: -30)
                .zIndex(3)
                .opacity(appearance)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .scaleEffect(pow(appearance, 2.0)*2.0 - appearance*4.0 + 3.0)
                .mask {
                    Rectangle()
                        .overlay() {
                            Circle()
                                .blendMode(.destinationOut)
                                .frame(width: changeRate ? 1000 : 0, height: changeRate ? 1000 : 0)
                        }
                        .compositingGroup()
                }

            // カメラの用意ができたら
            // FIXME: カメラ使用の設定が許可されているかで条件分岐
            if canAccessCam {
                if UserDefaults.standard.bool(forKey: "isFirstLaunch") {
                    SetupView()
                        .opacity(1 - self.appearance)
                        .zIndex(4)
                    if !vs.isLaunchApp {
                        BabbleParticle(zIndex: 5)
                    }
                } else {
                    // 2回目以降
                    MainView()
                        .zIndex(vs.isShowMainV ? 4 : 1)
                    if cam.canUse {
                        if !vs.isLaunchApp {
                            BabbleParticle(zIndex: 5)
                        }
                    }
                }
            }
        }
        .zIndex(appearance == 1 ? 2 : 0)
        .onChange(of: cam.canUse) {
            // 2回目以降
            if !UserDefaults.standard.bool(forKey: "isFirstLaunch") {
                if cam.canUse {
                    changeRate = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        vs.isShowMainV = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { // パーティクルの寿命と同じ時間
                            vs.isLaunchApp = true
                        }
                    }
                }
            }
        }
        .onAppear() {
            // カメラが許可されているかどうかの確認
            let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)

            if status == AVAuthorizationStatus.authorized {
                canAccessCam = true
            } else {
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        canAccessCam = true
                    } else {
                        canAccessCam = false
                        isShowAlert = true
                    }
                }
            }
        }
        .onChange(of: canAccessCam) {
            // 初回
            // FIXME: カメラ使用の設定が許可されているかで条件分岐
            if canAccessCam {
                if UserDefaults.standard.bool(forKey: "isFirstLaunch") {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        changeRate = true
                        appearance = 0.0
                    }
                }
            } else {
                isShowAlert = true
            }
        }
        .onChange(of: scenePhase) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if (scenePhase == .active && !canAccessCam) {
                    isShowAlert = true
                }
            }
        }
        .animation(
            .easeOut(duration: sceneChangeDuration),
            value: changeRate
        )
        .animation(
            .easeOut(duration: sceneChangeDuration),
            value: appearance
        )
        .alert("カメラが許可されていません", isPresented: $isShowAlert) {
            Button("キャンセル") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1 ) {
                    canAccessCam = false
                    isShowAlert = true
                }
            }
            Button("設定") {
                guard let settingsURL = URL(string: UIApplication.openSettingsURLString ) else {
                    return
                }
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }
    }
}
