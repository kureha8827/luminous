//
//  FitText.swift
//  luminous
//
//  Created by kureha8827 on 2024/08/21.
//

import SwiftUI

struct FitText: View {
    let text: String
    let font: Font

    init(_ text: String,_ font: Font = .system(size: 14)) {
        self.text = text
        self.font = font
    }
    var body: some View {
        Text(text).font(self.font)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
    }
}
