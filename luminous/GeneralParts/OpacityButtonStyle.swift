//
//  OpacityButtonStyle.swift
//  luminous
//
//  Created by kureha8827 on 2024/05/22.
//

import SwiftUI

/* ButtonStyle */

struct OpacityButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.opacity(1)
    }
}
