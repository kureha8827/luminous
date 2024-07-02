//
//  GenericParts.swift
//  luminous
//
//  Created by kureha8827 on 2024/03/16.
//

import SwiftUI

/* その他 */

class ViewSwitcher: ObservableObject {
    @Published var value: Int = 0
    @Published var isShowMainV: Bool = false
    @Published var isLaunchApp: Bool = false
}
