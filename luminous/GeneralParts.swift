//
//  GenericParts.swift
//  luminous
//
//  Created by kureha8827 on 2024/03/16.
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

/* ButtonStyle */

struct OpacityButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.opacity(1)
    }
}

/* その他 */

class ViewSwitcher: ObservableObject {
    @Published var value: Int = 0
    @Published var beforeValue: Int = 0
    @Published var isShowMainView: Bool = false
    @Published var isExistMainView: Bool = false
    @Published var deleteSetupView: Bool = false
    @Published var fromBeginViewToMainView: UIImage?
    @Published var isVisibleTabBar: Bool = true
    @Published var isShowFilterView: Double = 0.0
}
