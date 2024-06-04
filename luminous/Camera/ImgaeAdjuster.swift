//
//  ImgaeAdjuster.swift
//  luminous
//
//  Created by kureha8827 on 2024/05/22.
//

import SwiftUI

class ImageAdjuster {
    var size: [Float]
    init() {
        self.size = Array(repeating: Float(0), count: 10)
    }

    func brightness(_ img: CIImage) -> CIImage {
        // TODO: 調整(明るさ、コントラスト等)処理
        let filter = CIFilter(name: "CIColorControls")
        filter?.setValue(img, forKey: kCIInputImageKey)
        filter?.setValue(size[1] / 100 * 0.1, forKey: "inputBrightness")
        print("in. ImageAdjuster: \(size[1])")
        guard let resImage = filter?.outputImage else { return CIImage() }
        return resImage
    }
}
