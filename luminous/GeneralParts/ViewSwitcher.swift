//
//  GenericParts.swift
//  luminous
//
//  Created by kureha8827 on 2024/03/16.
//

import SwiftUI

/* その他 */

final class ViewSwitcher: ObservableObject, @unchecked Sendable {
    @Published var value: Int = 0
    @Published var isShowMainV: Bool = false
    @Published var isLaunchApp: Bool = false
}
