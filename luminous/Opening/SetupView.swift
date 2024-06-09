//
//  SetupView.swift
//  luminous
//
//  Created by kureha8827 on 2024/03/17.
//

import SwiftUI

struct SetupView: View {
    @State private var selectedTag = 1
    @State private var changeRate: Bool = false
    @State private var sceneChangeDuration = 0.6
    @EnvironmentObject var vs: ViewSwitcher
    @EnvironmentObject var cam: BaseCamera
    var body: some View {
        ZStack {
            MainView()
                .zIndex(vs.isShowMainV ? 4 : 1)
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
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            vs.isShowMainV = true
                        }
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.lightPurple)
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
            .zIndex(2)
            .ignoresSafeArea()
        }
        .zIndex(vs.isShowMainV ? -1 : 2)
    }
}
