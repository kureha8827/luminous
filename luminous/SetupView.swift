//
//  SetupView.swift
//  luminous
//
//  Created by kureha8827 on 2024/03/17.
//

import SwiftUI

struct SetupView: View {
    @State private var selectedTag = 1
    @State private var isShow: Bool = false
    @State private var isShowMainView: Bool = false
    @State private var opacityMainView: Double = 0
    @State private var changeRate: Bool = false
    @State private var sceneChangeDuration = 0.6
    @EnvironmentObject var viewSwitcher: ViewSwitcher
    @EnvironmentObject var cam: BaseCamView
    var body: some View {
        ZStack {
            TabView(selection: $selectedTag) {
                Group {
                    VStack {
                        Text("3").foregroundStyle(.white).font(.largeTitle)
                    }
                }
                .tag(1)

                Group {
                    VStack {
                        Text("2").foregroundStyle(.white).font(.largeTitle)
                    }
                }
                .tag(2)
                .onAppear() {
                    opacityMainView = 1
                }

                Group {
                    VStack {
                        Text("1").foregroundStyle(.white).font(.largeTitle)
                    }
                }
                .tag(3)

                Group {
                    VStack {
                        Text("START")
                            .foregroundStyle(.white)
                            .font(.system(size: 40))
                            .italic()
                            .tracking(6)
                    }
                }
                .tag(4)
                .onAppear() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        changeRate = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + sceneChangeDuration) {
                            UserDefaults.standard.set(false, forKey: "isFirstLaunch")
                            viewSwitcher.value = 10
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            viewSwitcher.deleteSetupView = true
                        }
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.purple2)
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
            .ignoresSafeArea()
        }
    }
}
