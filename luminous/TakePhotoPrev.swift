//
//  TakePhotoPrev.swift
//  luminous
//
//  Created by kureha8827 on 2024/03/31.
//

import SwiftUI

struct TakePhotoPrev: View {
    @EnvironmentObject var cam: BaseCamView
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            Image(uiImage: cam.uiImage)
                .resizable()
                .frame(width: UIScreen.main.bounds.width - 54, height: UIScreen.main.bounds.width*16/9 - 96)
                .padding(.bottom, 40)
            Button(
                action: {
//                    cam.isSaved = true
                    cam.takePhoto()
                },
                label: {
                    ZStack {
                        Circle()
                            .frame(width: 64)
                            .foregroundStyle(.white)
                        Image(systemName: "arrow.down.circle")
                            .font(.system(size: 58))
                            .foregroundStyle(Color.purple2)
                    }
                })
            .buttonStyle(OpacityButtonStyle())
            .offset(y: 360)
        }
    }
}
