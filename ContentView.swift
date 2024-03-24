//
//  ContentView.swift
//  luminous
//
//  Created by kureha8827 on 2024/03/15.
//

import SwiftUI

struct StartingView: View {
    @State var isShow: Bool = false
    var body: some View {
        ZStack {
            let anm = AnimationController()
            VStack {
                TitleView(scale: 1).offset(y: -30)
                if isShow {
                    anm.babbleParticle()
                        .edgesIgnoringSafeArea(.all)
                    SetupView()
                    self
                        .scaleEffect(3)
                        .transition(.opacity)
                }
                Button("particle") {
                    withAnimation(.linear(duration: 0.6)) {
                        self.isShow.toggle()
                    }
                }
            }
        }
    }
}

struct SetupView: View {
    var body: some View {
        VStack {
            Text("aaaa").foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.pink)
    }
}



struct StartingView_Previews: PreviewProvider {
    static var previews: some View {
        StartingView()
    }
}

struct SetupView_Previews: PreviewProvider {
    static var previews: some View {
        SetupView()
    }
}
