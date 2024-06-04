//
//  StartingView.swift
//  luminous
//
//  Created by kureha8827 on 2024/03/19.
//

import SwiftUI
import SpriteKit

struct BeginView: View {
    @State private var appearance = 1.0
    @State private var changeRate: Bool = false
    @State private var isChanged: Bool = false
    @State private var sceneChangeDuration = 0.6
    @EnvironmentObject var vs: ViewSwitcher
    @EnvironmentObject var cam: BaseCamView
    var body: some View {
        ZStack {
            // 2回目以降
            if !UserDefaults.standard.bool(forKey: "isFirstLaunch") {
                MainView()
                    .zIndex(vs.isShowMainV ? 4 : 1)
            }

/*
    ランダムで文字列を表示(minecraft的な)
 */

            TitleView(scale: 1)
                .offset(y: -30)
                .zIndex(2)
                .opacity(self.appearance)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.white)
                .ignoresSafeArea()
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
                .onAppear() {
                    // 初回
                    if UserDefaults.standard.bool(forKey: "isFirstLaunch") {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            changeRate = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                appearance = 0.0
                            }
                        }
                    }
                }
                .onChange(of: cam.canUse) {
                    // 2回目以降
                    if !UserDefaults.standard.bool(forKey: "isFirstLaunch") {
                        if cam.canUse {
                            changeRate = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                vs.isShowMainV = true
                            }
                        }
                    }
                }

            // カメラの用意ができたら
            if UserDefaults.standard.bool(forKey: "isFirstLaunch") {
                SetupView()
                    .opacity(1 - self.appearance)
                    .zIndex(4)  
            }
            BabbleParticle(zIndex: 5)
        }
        .zIndex(appearance == 1 ? 2 : 0)
        .animation(
            .easeOut(duration: sceneChangeDuration),
            value: changeRate
        )
        .animation(
            .easeOut(duration: sceneChangeDuration),
            value: appearance
        )
    }
}
