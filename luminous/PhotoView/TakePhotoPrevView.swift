//
//  TakePhotoPrevView.swift
//  luminous
//
//  Created by kureha8827 on 2024/03/31.
//

import SwiftUI

struct TakePhotoPrevView: View {
    @EnvironmentObject var cam: BaseCamera
    @EnvironmentObject var vs: ViewSwitcher
    var body: some View {
        VStack {
//            Color.white
//                .ignoresSafeArea()
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
            Group {
                if UIDevice.current.orientation.rawValue == 3 || UIDevice.current.orientation.rawValue == 4 {
                    Image(uiImage: cam.uiImage)
                        .resizable()
                        .frame(width: UIScreen.main.bounds.width - 54, height: (UIScreen.main.bounds.width - 54)/16*9)
                        .padding(.bottom, 20)
                } else {
                    Image(uiImage: cam.uiImage)
                        .resizable()
                        .frame(width: UIScreen.main.bounds.width - 54, height: (UIScreen.main.bounds.width - 54)*16/9)
                        .padding(.bottom, 20)
                }
            }
            .frame(width: UIScreen.main.bounds.width - 54, height: (UIScreen.main.bounds.width - 54)*16/9)
            
            HStack {
                Spacer()

                // 戻るボタン
                Button(
                    action: {
                        cam.takePhotoPrevTransition(false)
                        vs.value = 10
                    },
                    label: {
                        Image(systemName: "arrow.uturn.left")
                            .font(.system(size: 32))
                            .frame(width: 64)
                            .foregroundStyle(Color.gray)
                    }
                )

                Spacer()

                // 保存ボタン
                Button(
                    action: {
                        cam.takePhotoPrevTransition(true)
                        vs.value = 10
                    },
                    label: {
                        Image(systemName: "arrow.down.circle")
                            .font(.system(size: 64))
                            .frame(width: 64)
                            .foregroundStyle(.lightPurple)
                    }
                )

                Spacer()

                // UIを整えるための空のパーツ
                Circle()
                    .frame(width: 64)
                    .opacity(0)

                Spacer()
            }
        }
    }
}
