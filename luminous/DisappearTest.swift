//
//  DisappearTest.swift
//  luminous
//
//  Created by kureha8827 on 2024/03/20.
//

import SwiftUI

struct DisappearTest: View {
    @State var opacity: CGFloat = 1
    @State var isShow: Bool = false
    var body: some View {
        VStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            Button("button") {
                withAnimation(Animation.linear(duration: 1)) {
                    opacity = 0
                }
                print("button")
                isShow = true
            }
            Toggle(isOn: $isShow) {
                
            }
        }
        .scaleEffect(opacity)
        .onAppear {
            print("onAppear")
        }
        .onDisappear() {
            print("onDisappear")
        }
        
        if isShow {
            TextSub()
        }
    }
}

struct TextSub: View {
    var body: some View {
        Text("ssssssssss")
            .onAppear() {
                print("TextSub")
            }
    }
}

#Preview {
    DisappearTest()
}
