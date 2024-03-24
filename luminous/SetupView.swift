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
    var body: some View {
        ZStack {
            MainView()
                .contentShape(.interaction, Rectangle().scale(opacityMainView))
                .opacity(opacityMainView)
                .zIndex(isShowMainView ? 3 : 0)

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
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        changeRate = true
                        UserDefaults.standard.set(false, forKey: "isFirstLaunch")
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.4) {
                            isShow = true
                            isShowMainView = true
                        }
                    }
                }
            }
            .background(.purple2)
            .tabViewStyle(PageTabViewStyle())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        }
    }
}

struct SetupView_Previews: PreviewProvider {
    static var previews: some View {
        SetupView()
    }
}
