//
//  ImgaeAdjuster.swift
//  luminous
//
//  Created by kureha8827 on 2024/05/22.
//

import SwiftUI

// TODO: フィルタ作成で用いる際はこのクラスを継承する
class ImageAdjuster {
    var size: [Float]
    init() {
        self.size = Array(repeating: Float(0), count: 11)
    }

    // 1: 明るさ
    func brightness(_ img: CIImage) -> CIImage {
        let filter = CIFilter(name: "CIExposureAdjust")
        filter?.setValue(img, forKey: kCIInputImageKey)
        filter?.setValue(size[1] >= 0 ? size[1] / 100 : size[1] / 100 * 3, forKey: "inputEV")
        guard let resImage = filter?.outputImage else { return CIImage() }
        return resImage
    }

//    func brightness(_ img: CIImage) -> CIImage {
//        let filter = CIFilter(name: "CIGammaAdjust")
//        filter?.setValue(img, forKey: kCIInputImageKey)
//        filter?.setValue(pow(2, -size[1] / 100), forKey: "inputPower")
//        guard let resImage = filter?.outputImage else { return CIImage() }
//        return resImage
//    }

    // 2: コントラスト
    func contrast(_ img: CIImage) -> CIImage {
        let filter = CIFilter(name: "CIToneCurve")
        filter?.setValue(img, forKey: kCIInputImageKey)
        filter?.setValue(CIVector(x: 0.0, y: 0.0), forKey: "inputPoint0")
        filter?.setValue(CIVector(x: 0.25, y: CGFloat(-size[2]/100/8 + 0.25)), forKey: "inputPoint1")
        filter?.setValue(CIVector(x: 0.5, y: 0.5), forKey: "inputPoint2")
        filter?.setValue(CIVector(x: 0.75, y: CGFloat(size[2]/100/8 + 0.75)), forKey: "inputPoint3")
        filter?.setValue(CIVector(x: 1.0, y: 1.0), forKey: "inputPoint4")
        guard let resImage = filter?.outputImage else { return CIImage() }
        return resImage
    }

    // 3: 彩度
    func saturation(_ img: CIImage) -> CIImage {
        let filter = CIFilter(name: "CIColorControls")
        filter?.setValue(img, forKey: kCIInputImageKey)
        filter?.setValue(size[3] / 100 + 1, forKey: "inputSaturation")
        guard let resImage = filter?.outputImage else { return CIImage() }
        return resImage
    }

    // 4: 自然な彩度
    func vibrance(_ img: CIImage) -> CIImage {
        let filter = CIFilter(name: "CIVibrance")
        filter?.setValue(img, forKey: kCIInputImageKey)
        filter?.setValue(size[4] / 100, forKey: "inputAmount")
        guard let resImage = filter?.outputImage else { return CIImage() }
        return resImage
    }

    // 5: シャドウ
    func shadow(_ img: CIImage) -> CIImage {
        let filter = CIFilter(name: "CIHighlightShadowAdjust")
        filter?.setValue(img, forKey: kCIInputImageKey)
        filter?.setValue(size[5] / 100, forKey: "inputShadowAmount")
        filter?.setValue(1, forKey: "inputRadius")
        guard let resImage = filter?.outputImage else { return CIImage() }
        return resImage
    }

    // 6: ハイライト
    func highlight(_ img: CIImage) -> CIImage {
        let filter = CIFilter(name: "CIHighlightShadowAdjust")
        filter?.setValue(img, forKey: kCIInputImageKey)
        filter?.setValue(size[6] / 100, forKey: "inputHighlightAmount")
        filter?.setValue(1, forKey: "inputRadius")
        guard let resImage = filter?.outputImage else { return CIImage() }
        return resImage
    }

    // 7: 色温度
    func temperature(_ img: CIImage) -> CIImage {
        let filter = CIFilter(name: "CITemperatureAndTint")
        filter?.setValue(img, forKey: kCIInputImageKey)
        filter?.setValue(CIVector(x: CGFloat(size[7] / 100 * 3000) + 6500, y: 0), forKey: "inputNeutral")
        filter?.setValue(CIVector(x: 6500, y: 0), forKey: "inputTargetNeutral")
        guard let resImage = filter?.outputImage else { return CIImage() }
        return resImage
    }

    // 8: 色相
    func hue(_ img: CIImage) -> CIImage {
        let filter = CIFilter(name: "CIHueAdjust")
        filter?.setValue(img, forKey: kCIInputImageKey)
        filter?.setValue(size[8] / 100 * Float.pi, forKey: "inputAngle")
        guard let resImage = filter?.outputImage else { return CIImage() }
        return resImage
    }

    // 9: 鮮鋭化
    func sharpness(_ img: CIImage) -> CIImage {
        let filter = CIFilter(name: "CIUnsharpMask")
        filter?.setValue(img, forKey: kCIInputImageKey)
        filter?.setValue(size[9] / 100 * 5, forKey: "inputIntensity")
        filter?.setValue(0.5, forKey: "inputRadius")
        guard let resImage = filter?.outputImage else { return CIImage() }
        return resImage
    }

    // 10: 平滑化フィルタ
    func gaussian(_ img: CIImage) -> CIImage {
        let radius = size[10] / 100 * 1.5
        let extent = img.extent
        let clampedExtent = extent.insetBy(dx: CGFloat(radius) * -3.21, dy: CGFloat(radius) * -3.21)

        let blur = CIFilter(name: "CIGaussianBlur")
        blur?.setValue(img.clampedToExtent().cropped(to: clampedExtent), forKey: kCIInputImageKey)
        blur?.setValue(radius, forKey: "inputRadius")

        guard let resImage = blur?.outputImage?.cropped(to: extent) else { return CIImage() }
        return resImage
    }


//    func gaussian(_ img: CIImage) -> CIImage {
//        let radius = size[10] / 100 * 1.5
//        let extent = img.extent
//        let clampedExtent = extent.insetBy(dx: CGFloat(radius) * -3.21, dy: CGFloat(radius) * -3.21)
//        let filter = CIFilter(name: "CIGaussianBlur")
//        filter?.setValue(img.clampedToExtent().cropped(to: clampedExtent), forKey: kCIInputImageKey)
//        filter?.setValue(radius, forKey: "inputRadius")
//        guard let resImage = filter?.outputImage?.cropped(to: extent) else { return CIImage() }
//        return resImage
//    }
}
