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
    @State private var isShow: Bool = false
    @State private var isShowMainView: Bool = false
    let anm = AnimationController()
//    @EnvironmentObject var cam: BaseCamView
    var body: some View {
        ZStack {
            // Layer1/4
            MainView()
                .zIndex(isShowMainView ? 5 : 1)

            // Layer2
            VStack {
                TitleView(scale: 1).offset(y: -30)
                Button("particle") {
                    isShow = true

                    if UserDefaults.standard.bool(forKey: "isFirstLaunch") {
                        withAnimation(Animation.linear(duration: 0.6)) {
                            disappear = 0
                        }
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            changeRate = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                isShowMainView = true
                            }
                        }
                    }
                }
            }
            .opacity(self.disappear)
            .scaleEffect(pow(disappear, 2)*2 - disappear*4 + 3)
            .zIndex(2)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.white)
            .mask {
                Rectangle()
                    .overlay() {
                        Circle()
                            .blendMode(.destinationOut)
                            .frame(width: changeRate ? 1000 : 0, height: changeRate ? 1000 : 0)
                            .animation(.easeOut(duration: 0.4), value: changeRate)
                    }
                    .compositingGroup()
            }
            .ignoresSafeArea()

            // Layer3-4
            if isShow {
                if UserDefaults.standard.bool(forKey: "isFirstLaunch") {
                    SetupView()
                        .opacity(1.0 - self.disappear)
                        .zIndex(4)    // 数値の小さいものが背面
                }
                anm.babbleParticle()
            }
        }
    }
}
