//
//  StartingView.swift
//  luminous
//
//  Created by kureha8827 on 2024/03/19.
//

import SwiftUI

struct StartingView: View {
//    @State private var isShow: Bool = false
    @State private var disappear = 1.0
    @State private var changeRate: CGFloat = 0
    @State private var isShow: Bool = false
    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = true
//    @AppStorage("FirstOpen") var firstOpen: Bool = true
    let anm = AnimationController()
    var body: some View {
        ZStack {
            VStack {
                TitleView(scale: 1).offset(y: -30)
                Button("particle") {
                    isShow = true
                
                    if isFirstLaunch {
                        withAnimation(Animation.linear(duration: 0.6)) {
                            disappear = 0
                        }
                    } else {
                        withAnimation(Animation.easeIn(duration: 0.25)) {
                            changeRate = 1000
                        }
                    }
                }
            }
            .opacity(self.disappear)
            .scaleEffect(pow(disappear, 2)*2 - disappear*4 + 3)
            .onAppear() {
            }
            
            if isShow {
                
                let _ = print("0: \(isFirstLaunch)")
                
                if isFirstLaunch {
                    let _ = print("isFirstLaunch")
                    SetupView()
                        .opacity(1.0 - self.disappear)
                        .zIndex(1)
                    
                } else {
                    let _ = print("isFirstLaunch - else")
                    Circle()
                        .fill(.white)
                        .frame(width: changeRate*1.02, height: changeRate*1.02)
                    
                    MainView()
                        .clipShape(Circle())
                        .frame(width: changeRate, height: changeRate)
                }
                
                anm.babbleParticle()
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
}



//struct SceneChangeToMainView: View {
//    var changeRate: CGFloat
//    var isActive:
//    var body: some View {
//        Circle()
//            .fill(.white)
//            .frame(width: changeRate*1.02, height: changeRate*1.02)
//        
//        MainView()
//            .clipShape(Circle())
//            .frame(width: changeRate, height: changeRate)
//    }
//}

#Preview {
    StartingView().environmentObject(GeneralValue())
}
