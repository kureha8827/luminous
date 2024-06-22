//
//  OptionView.swift
//  luminous
//
//  Created by kureha8827 on 2024/06/21.
//

import SwiftUI

struct OptionView: View {
    @EnvironmentObject var vs: ViewSwitcher
    @EnvironmentObject var cam: BaseCamera
    var option = OptionClass()
    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            // 以下の警告に対応するために id: \.self を追加
            // Non-constant range: argument must be an integer literal
            ForEach(0..<ConstStruct.optionNum, id: \.self) { i in
                Button(action: {
                    option.main(i)  // iの値によってそれぞれのオプションを実行
                }, label: {
                    VStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .foregroundStyle(.gray)
                                .opacity(0.5)
                            Circle()
                                .stroke(.white, lineWidth: 1)
                            OptionClass.ImageView(i)
                        }
                        .frame(width: 48, height: 48)
                        Text("\(option.imageName(i))")
                            .foregroundStyle(.gray63)
                            .font(.system(size: 12))
                            .fontWeight(.thin)
                    }
                })
            }
        }
        .frame(height: 60)
    }
}
