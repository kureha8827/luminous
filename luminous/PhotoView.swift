//
//  PhotoView.swift
//  luminous
//
//  Created by kureha8827 on 2024/03/25.
//

import SwiftUI

struct PhotoView: View {
    @EnvironmentObject var cam: BaseCamView  // 初期状態は背面カメラ
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                Image(uiImage: cam.uiImage)
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 16 / 9)
                    .padding(.top, 10)
                Button(
                    action: {
                        cam.isTaking = true
                        cam.canUse = false
                        cam.session.stopRunning()
                    },
                    label: {
                        ZStack {
                            Circle()
                                .frame(width: 64)
                                .foregroundStyle(.purple2)
                            Circle()
                                .frame(width: 58)
                                .foregroundStyle(.white)
                        }
                    })
                .buttonStyle(OpacityButtonStyle())
                .offset(y: 335)

                if cam.isTaking {
                    TakePhotoPrev()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(
                        action: {
                            DispatchQueue.main.async {
                                cam.isCameraBack.toggle()
                                cam.changeCam()
                            }
                        },
                        label: {
                            Label("", systemImage: "arrow.triangle.2.circlepath")
                        }
                    )
                    .tint(.black.opacity(0.7))
//                    .padding(.bottom, 5)
                }
            }
            .onAppear() {
                cam.captureSession()
            }
        }
    }
}
