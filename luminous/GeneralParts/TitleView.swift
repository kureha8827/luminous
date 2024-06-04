//
//  TitleView.swift
//  luminous
//
//  Created by kureha8827 on 2024/05/22.
//

import SwiftUI

/* ロゴ */

struct TitleView: View {
    var scale: CGFloat = 1
    var body: some View {
        HStack {
            Text("LUMIN").offset(x: 10)
            Image(systemName: "scope").font(.system(size: 36 * scale))
            Text("US").offset(x: -7)
        }
        .font(.system(size: 40 * scale))
        .italic()
        .foregroundColor(.lightPurple)
        .tracking(6)
    }
}
