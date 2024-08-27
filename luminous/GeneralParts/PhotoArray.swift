//
//  PhotoArray.swift
//  luminous
//
//  Created by kureha8827 on 2024/05/22.
//

import Foundation

// リサイズができるように拡張
struct PhotoArray {
    let imgFilter = [
        "original",
        "cottonCandy",
        "ramune",
        "cherryBlossoms",
        "dark",
        "violet",
        "150x150",
        "150x150",
        "150x150",
        "150x150"
    ]

    let imgAdjuster = [
        "original",
        "brightness",
        "contrast",
        "saturation",
        "vibrance",
        "shadow",
        "highlight",
        "temperature",
        "tint",
        "sharpness",
        "gaussian"
    ]

    let imgBeauty = [
        "face",
        "skin",
        "makeup"
    ]
}
