//
//  TakePhotoPrev.swift
//  luminous
//
//  Created by kureha8827 on 2024/03/31.
//

import SwiftUI

struct TakePhotoPrev: View {
    @EnvironmentObject var cam: BaseCamView
    @EnvironmentObject var viewSwitcher: ViewSwitcher
    var body: some View {
        VStack {
//            Color.white
//                .ignoresSafeArea()
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
            Image(uiImage: cam.uiImage)
                .resizable()
                .frame(width: UIScreen.main.bounds.width - 54, height: UIScreen.main.bounds.width*16/9 - 96)
                .padding(.bottom, 20)
            HStack {
                Spacer()

                // 戻るボタン
                Button(
                    action: {
                        cam.takePhotoPrevTransition(false)
                        viewSwitcher.value = 10
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
                        viewSwitcher.value = 10
                    },
                    label: {
                        Image(systemName: "arrow.down.circle")
                            .font(.system(size: 64))
                            .frame(width: 64)
                            .foregroundStyle(.purple2)
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
