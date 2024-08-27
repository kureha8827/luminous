//
//  ImageFilter.swift
//  luminous
//
//  Created by kureha8827 on 2024/05/22.
//

import SwiftUI

class ImageFilter {
    var adjuster = ImageAdjuster()
    var size: [Int]
    init(size: [Int]) {
        self.size = size
    }


    func output(_ img: inout CIImage, _ cur: Int) {
        // フィルタ関数の列挙
        switch cur {
        case 1: cottonCandy(&img)
        case 2: ramune(&img)
        case 3: cherryBlossoms(&img)
        case 4: dark(&img)
        case 5: violet(&img)
        default: return
        }
    }


    // 1: わたあめ 目安: 70
    func cottonCandy(_ img: inout CIImage) {
        guard let brightness = CIFilter(name: "CIColorControls") else { return }
        brightness.setValue(img, forKey: kCIInputImageKey)
        brightness.setValue(size[1] / 100 / 10, forKey: "inputBrightness")
        if let brightnessImg = brightness.outputImage {
            img = brightnessImg
        }
        adjuster.contrast(&img, size[1] / 100 * 20)
        adjuster.saturation(&img, size[1] / 100 * -20)
        adjuster.vibrance(&img, size[1] / 100 * -45)
        adjuster.temperature(&img, size[1] / 100 * -25)
    }

    // 2: ラムネ 目安: 70
    func ramune(_ img: inout CIImage) {
        guard let brightness = CIFilter(name: "CIColorControls") else { return }
        brightness.setValue(img, forKey: kCIInputImageKey)
        brightness.setValue(Float(size[2]) / 100 * 0.10, forKey: "inputBrightness")
        if let brightnessImg = brightness.outputImage {
            img = brightnessImg
        }
        adjuster.brightness(&img, size[2] / 100 * -5)
        adjuster.contrast(&img, size[5] / 100 * 20)
        adjuster.saturation(&img, size[5] / 100 * -30)
        adjuster.vibrance(&img, size[5] / 100 * -60)
        adjuster.temperature(&img, size[2] / 100 * -100)
    }

    // 3: 桜 目安: 70
    func cherryBlossoms(_ img: inout CIImage) {
        guard let brightness = CIFilter(name: "CIColorControls") else { return }
        brightness.setValue(img, forKey: kCIInputImageKey)
        brightness.setValue(Float(size[3]) / 100 * 0.10, forKey: "inputBrightness")
        if let brightnessImg = brightness.outputImage {
            img = brightnessImg
        }
        adjuster.brightness(&img, size[3] / 100 * -5)
        adjuster.contrast(&img, size[5] / 100 * 20)
        adjuster.saturation(&img, size[5] / 100 * -30)
        adjuster.vibrance(&img, size[5] / 100 * -60)
        adjuster.tint(&img, size[3] / 100 * 100)
    }

    // 4: ダーク 目安: 50
    func dark(_ img: inout CIImage) {
        adjuster.brightness(&img, size[4] / 100 * -130)
        adjuster.contrast(&img, size[4] / 100 * 30)
        adjuster.saturation(&img, size[4] / 100 * -90)
        adjuster.vibrance(&img, size[4] / 100 * -200)
        adjuster.shadow(&img, size[4] / 100 * -50)
        adjuster.temperature(&img, size[4] / 100 * -10)
    }

    // 5: バイオレット 目安: 80
    func violet(_ img: inout CIImage) {
        guard let brightness = CIFilter(name: "CIColorControls") else { return }
        brightness.setValue(img, forKey: kCIInputImageKey)
        brightness.setValue(Float(size[5]) / 100 * 0.10, forKey: "inputBrightness")
        if let brightnessImg = brightness.outputImage {
            img = brightnessImg
        }
        adjuster.brightness(&img, size[5] / 100 * -5)
        adjuster.contrast(&img, size[5] / 100 * 20)
        adjuster.saturation(&img, size[5] / 100 * -30)
        adjuster.vibrance(&img, size[5] / 100 * -60)
        adjuster.temperature(&img, size[5] / 100 * -100)
        adjuster.tint(&img, size[5] / 100 * 80)
    }
}
