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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            cam.camFormatter()
            Button(
                action: {
                    cam.isSaved = true
                },
                label: {
                    ZStack {
                        Circle()
                            .frame(width: 64)
                            .foregroundStyle(.white)
                        Image(systemName: "arrow.down.circle")
                            .font(.system(size: 58))
                            .foregroundStyle(.purple2)
                    }
                })
            .buttonStyle(OpacityButtonStyle())
            .offset(y: 360)
        }
    }
}
