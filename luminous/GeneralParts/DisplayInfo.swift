//
//  DisplayInfo.swift
//  luminous
//
//  Created by kureha8827 on 2024/07/03.
//

import SwiftUI

@MainActor
struct DisplayInfo {
    private static var window: UIWindowScene? = UIApplication.shared.connectedScenes.first as? UIWindowScene

    static var screenSize: CGRect = window?.screen.bounds ?? CGRect.zero

    static var width: CGFloat {
        return screenSize.width
    }

    static var height: CGFloat {
        return screenSize.height
    }
}
