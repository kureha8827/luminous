//
//  StartingView.swift
//  luminous
//
//  Created by kureha8827 on 2024/03/19.
//

import SwiftUI
import SpriteKit

struct BeginView: View {
    @State private var disappear = 1.0
    @State private var changeRate: Bool = false
    @State private var isChanged: Bool = false
    @State private var sceneChangeDuration = 0.6
    @EnvironmentObject var viewSwitcher: ViewSwitcher
    @EnvironmentObject var cam: BaseCamView
    var body: some View {
        ZStack {
            MainView()
                .zIndex(isChanged ? 4 : 1)

/*
    ランダムで文字列を表示(minecraft的な)
 */

            TitleView(scale: 1)
                .offset(y: -30)
                .zIndex(2)
                .opacity(self.disappear)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.white)
                .ignoresSafeArea()
                .scaleEffect(pow(disappear, 2)*2 - disappear*4 + 3)
                .mask {
                    Rectangle()
                        .overlay() {
                            Circle()
                                .blendMode(.destinationOut)
                                .frame(width: changeRate ? 1000 : 0, height: changeRate ? 1000 : 0)
                                .animation(.easeOut(duration: sceneChangeDuration), value: changeRate)
                        }
                        .compositingGroup()
                }
                .onChange(of: cam.canUse) {
                    if cam.canUse {
                        if UserDefaults.standard.bool(forKey: "isFirstLaunch") {
                            withAnimation(Animation.linear(duration: sceneChangeDuration)) {
                                disappear = 0
                            }
                        } else {
                            changeRate = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                isChanged = true
                            }
                        }
                    }
                }

            // カメラの用意ができたら
            if cam.canUse {
                if UserDefaults.standard.bool(forKey: "isFirstLaunch") {
                    if !viewSwitcher.deleteSetupView {
                        SetupView()
                            .opacity(1 - self.disappear)
                            .zIndex(4)
                    }
                }
                BabbleParticle(zIndex: 5)
            }
        }
        .onDisappear() {
            print("onDisappear")
        }
    }
}
