//
//  ImgaeAdjuster.swift
//  luminous
//
//  Created by kureha8827 on 2024/05/22.
//

import SwiftUI

// TODO: フィルタ作成で用いる際はこのクラスを用いる
class ImageAdjuster {
    var size: [Int] = []

    func output(_ img: inout CIImage) {
        brightness(&img)
        contrast(&img)
        saturation(&img)
        vibrance(&img)
        shadow(&img)
        highlight(&img)
        temperature(&img)
        tint(&img)
        sharpness(&img)
        gaussian(&img)
    }

    // 1: 明るさ
    func brightness(_ img: inout CIImage, _ size: Int? = nil) {
        var param: Int
        if size == nil {
            param = self.size[1]
        } else {
            param = size!   // nilではないことが確定しているためOK
        }
        guard let filter = CIFilter(name: "CIExposureAdjust") else { return }
        filter.setValue(img, forKey: kCIInputImageKey)
        filter.setValue(param >= 0 ? param / 100 : param / 100 * 3, forKey: "inputEV")
        if let res = filter.outputImage {
            img = res
        }
    }

    // 2: コントラスト
    func contrast(_ img: inout CIImage, _ size: Int? = nil) {
        var param: CGFloat
        if size == nil {
            param = CGFloat(self.size[2])
        } else {
            param = CGFloat(size!)
        }
        guard let filter = CIFilter(name: "CIToneCurve") else { return }
        filter.setValue(img, forKey: kCIInputImageKey)
        filter.setValue(CIVector(x: 0.0, y: 0.0), forKey: "inputPoint0")
        filter.setValue(CIVector(x: 0.25, y: CGFloat(-param/100/8 + 0.25)), forKey: "inputPoint1")
        filter.setValue(CIVector(x: 0.5, y: 0.5), forKey: "inputPoint2")
        filter.setValue(CIVector(x: 0.75, y: CGFloat(param/100/8 + 0.75)), forKey: "inputPoint3")
        filter.setValue(CIVector(x: 1.0, y: 1.0), forKey: "inputPoint4")
        if let res = filter.outputImage {
            img = res
        }
    }

    // 3: 彩度
    func saturation(_ img: inout CIImage, _ size: Int? = nil) {
        var param: Int
        if size == nil {
            param = self.size[3]
        } else {
            param = size!
        }
        guard let filter = CIFilter(name: "CIColorControls") else { return }
        filter.setValue(img, forKey: kCIInputImageKey)
        filter.setValue(param / 100 + 1, forKey: "inputSaturation")
        if let res = filter.outputImage {
            img = res
        }
    }

    // 4: 自然な彩度
    func vibrance(_ img: inout CIImage, _ size: Int? = nil) {
        var param: Int
        if size == nil {
            param = self.size[4]
        } else {
            param = size!
        }
        guard let filter = CIFilter(name: "CIVibrance") else { return }
        filter.setValue(img, forKey: kCIInputImageKey)
        filter.setValue(param / 100, forKey: "inputAmount")
        if let res = filter.outputImage {
            img = res
        }
    }

    // 5: シャドウ
    func shadow(_ img: inout CIImage, _ size: Int? = nil) {
        var param: Int
        if size == nil {
            param = self.size[5]
        } else {
            param = size!
        }
        guard let filter = CIFilter(name: "CIHighlightShadowAdjust") else { return }
        filter.setValue(img, forKey: kCIInputImageKey)
        filter.setValue(param / 100, forKey: "inputShadowAmount")
        filter.setValue(1, forKey: "inputRadius")
        if let res = filter.outputImage {
            img = res
        }
    }

    // 6: ハイライト
    func highlight(_ img: inout CIImage, _ size: Int? = nil) {
        var param: Int
        if size == nil {
            param = self.size[6]
        } else {
            param = size!
        }

        guard let positive = CIFilter(name: "CIGammaAdjust") else { return }
        guard let negative = CIFilter(name: "CIHighlightShadowAdjust") else { return }

        if param >= 0 {
            positive.setValue(img, forKey: kCIInputImageKey)
            positive.setValue(pow(2, -param / 100), forKey: "inputPower")
            if let res = positive.outputImage {
                img = res
            }
        } else {
            negative.setValue(img, forKey: kCIInputImageKey)
            negative.setValue((param / 100 + 1), forKey: "inputHighlightAmount")
            negative.setValue(1, forKey: "inputRadius")
            if let res = negative.outputImage {
                img = res
            }
        }

    }

    // 7: 色温度
    func temperature(_ img: inout CIImage, _ size: Int? = nil) {
        var param: Int
        if size == nil {
            param = self.size[7]
        } else {
            param = size!
        }
        guard let filter = CIFilter(name: "CITemperatureAndTint") else { return }
        filter.setValue(img, forKey: kCIInputImageKey)
        filter.setValue(CIVector(x: CGFloat(param / 100 * 3000) + 6500, y: 0), forKey: "inputNeutral")
        filter.setValue(CIVector(x: 6500, y: 0), forKey: "inputTargetNeutral")
        if let res = filter.outputImage {
            img = res
        }
    }

    // 8: 色相
    func tint(_ img: inout CIImage, _ size: Int? = nil) {
        var param: Int
        if size == nil {
            param = self.size[8]
        } else {
            param = size!
        }
        guard let filter = CIFilter(name: "CITemperatureAndTint") else { return }
        filter.setValue(img, forKey: kCIInputImageKey)
        filter.setValue(CIVector(x: 6500, y: CGFloat(param / 100 * 100)), forKey: "inputNeutral")
        filter.setValue(CIVector(x: 6500, y: 0), forKey: "inputTargetNeutral")
        if let res = filter.outputImage {
            img = res
        }
    }


//    func hue(_ img: inout CIImage, _ size: Int? = nil) {
//        var param: Int
//        if size == nil {
//            param = self.size[8]
//        } else {
//            param = size!
//        }
//        guard let filter = CIFilter(name: "CIHueAdjust") else { return }
//        filter.setValue(img, forKey: kCIInputImageKey)
//        filter.setValue(param / 100 * Int.pi, forKey: "inputAngle")
//        if let res = filter.outputImage {
//            img = res
//        }
//    }

    // 9: 鮮鋭化
    func sharpness(_ img: inout CIImage, _ size: Int? = nil) {
        var param: Int
        if size == nil {
            param = self.size[9]
        } else {
            param = size!
        }
        guard let filter = CIFilter(name: "CIUnsharpMask") else { return }
        filter.setValue(img, forKey: kCIInputImageKey)
        filter.setValue(param / 100 * 5, forKey: "inputIntensity")
        filter.setValue(0.5, forKey: "inputRadius")
        if let res = filter.outputImage {
            img = res
        }
    }

    // 10: 平滑化フィルタ
    func gaussian(_ img: inout CIImage, _ size: Int? = nil) {
        var param: CGFloat
        if size == nil {
            param = CGFloat(self.size[10])
        } else {
            param = CGFloat(size!)
        }
        let radius = param / 100 * 1.5
        let extent = img.extent
        let clampedExtent = extent.insetBy(dx: CGFloat(radius) * -3.21, dy: CGFloat(radius) * -3.21)

        guard let blur = CIFilter(name: "CIGaussianBlur") else { return }
        blur.setValue(img.clampedToExtent().cropped(to: clampedExtent), forKey: kCIInputImageKey)
        blur.setValue(radius, forKey: "inputRadius")
        if let res = blur.outputImage?.cropped(to: extent) {
            img = res
        }
    }
}
