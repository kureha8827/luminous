//
//  FromBeginToMain.swift
//  luminous
//
//  Created by kureha8827 on 2024/04/27.
//

import SwiftUI

struct FromBeginToMain: View {
    @State private var isShow: Bool = false
    @State private var disappear = 1.0
    @State private var changeRate: Bool = false
    @EnvironmentObject var viewSwitcher: ViewSwitcher
    @EnvironmentObject var cam: BaseCamView

    var body: some View {
        ZStack {
            // nilじゃないなら実行
            // BeginViewの最終時点のView画像
            if cam.canUse {
                if let image = viewSwitcher.fromBeginViewToMainView {
                    Image(uiImage: image).frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }

        }
        .opacity(self.disappear)
        .scaleEffect(pow(disappear, 2)*2 - disappear*4 + 3)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white)
        .mask {
            Rectangle()
                .overlay() {
                    Circle()
                        .blendMode(.destinationOut)
                        .frame(width: changeRate ? 1000 : 0, height: changeRate ? 1000 : 0)
                        .animation(.easeOut(duration: 0.8), value: changeRate)
                }
                .compositingGroup()
        }
        .ignoresSafeArea()
        .onAppear() {
            if UserDefaults.standard.bool(forKey: "isFirstLaunch") {
                withAnimation(Animation.linear(duration: 0.6)) {
                    disappear = 0
                }
            } else {
                    changeRate = true
            }
        }
    }
}
