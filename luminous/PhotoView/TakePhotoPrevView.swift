//
//  TakePhotoPrevView.swift
//  luminous
//
//  Created by kureha8827 on 2024/03/31.
//

import SwiftUI

@MainActor
struct TakePhotoPrevView: View {
    @EnvironmentObject var cam: BaseCamera
    @EnvironmentObject var vs: ViewSwitcher
    @State private var available = true
    var body: some View {
        VStack {
//            Color.white
//                .ignoresSafeArea()
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
            Group {
                if UIDevice.current.orientation.rawValue == 3 || UIDevice.current.orientation.rawValue == 4 {
                    Image(uiImage: cam.uiImage)
                        .resizable()
                        .frame(width: DisplayInfo.width - 54, height: (DisplayInfo.width - 54)/16*9)
                        .padding(.bottom, 20)
                } else {
                    Image(uiImage: cam.uiImage)
                        .resizable()
                        .frame(width: DisplayInfo.width - 54, height: (DisplayInfo.width - 54)*16/9)
                        .padding(.bottom, 20)
                }
            }
            .frame(width: DisplayInfo.width - 54, height: (DisplayInfo.width - 54)*16/9)
            
            HStack {
                Spacer()

                // 戻るボタン
                Button(
                    action: {
                        Task { @MainActor in
                            await Task {
                                available = false
                            }.value
                            await Task.detached(priority: .background) {
                                await cam.startSession()
                            }.value
                            await Task { @MainActor in
                                vs.value = 10
                            }.value
                        }
                    },
                    label: {
                        Image(systemName: "arrow.uturn.left")
                            .font(.system(size: 32))
                            .frame(width: 64)
                            .foregroundStyle(Color.gray)
                    }
                )
                .disabled(!available)

                Spacer()

                // 保存ボタン
                Button(
                    action: {
                        Task { @MainActor in
                            await Task {
                                available = false
                            }.value
                            await Task.detached(priority: .background) {
                                await UIImageWriteToSavedPhotosAlbum(cam.uiImage, nil, nil, nil)
                                await cam.startSession()
                            }.value
                            await Task { @MainActor in
                                vs.value = 10
                            }.value
                        }
                    },
                    label: {
                        Image(systemName: "arrow.down.circle")
                            .font(.system(size: 64))
                            .frame(width: 64)
                            .foregroundStyle(.lightPurple)
                    }
                )
                .disabled(!available)

                Spacer()

                // UIを整えるための空のパーツ
                Circle()
                    .frame(width: 64)
                    .opacity(0)

                Spacer()
            }
        }
        .onDisappear() {
            available = true
        }
    }
}
