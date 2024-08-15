//
//  CameraFormatter.swift
//  luminous
//
//  Created by kureha8827 on 2024/08/02.
//

import SwiftUI

// カメラから取得した画像を加工する関数群
struct CameraFormatter {
    @MainActor
    func uiImageRotation(_ uiImage: inout UIImage) async {
        var ciImage: CIImage
        if let img = uiImage.cgImage {
            ciImage = CIImage(cgImage: img)
        } else {
            return
        }

        // 画面の向きを考慮した画像の取得
        let rot = UIDevice.current.orientation.rawValue
        ciImage = ciImage.transformed(by: CGAffineTransform(rotationAngle: round(-90.0*powl(Double(rot)-3.5+1.0/(4.0*Double(rot)-14.0), -11))*Double.pi/180.0))
        let context = CIContext()
        let cgImage: CGImage? = context.createCGImage(ciImage, from: ciImage.extent)

        // UIImageに変換
        if let img = cgImage {
            uiImage = UIImage(cgImage: img, scale: 3, orientation: .right)
        }
    }
    

    func cropImageTo3x4(cgImage: CGImage) -> UIImage {
        // 元の画像のサイズを取得
        let originalWidth = CGFloat(cgImage.width)
        let originalHeight = CGFloat(cgImage.height)

        // 切り抜き後のサイズを計算
        let cropHeight = originalHeight
        let cropWidth = cropHeight * 4.0 / 3.0

        // 切り抜き領域のY座標を計算 (中央から切り抜く場合)
        let cropX = (originalWidth - cropWidth) / 2.0
        let cropRect = CGRect(x: cropX, y: 0, width: cropWidth, height: cropHeight)

        // CGImageを用いて切り抜き
        guard let croppedCGImage = cgImage.cropping(to: cropRect) else {
            return UIImage()
        }

        // 切り抜いたCGImageからUIImageを作成
        let croppedImage = UIImage(cgImage: croppedCGImage, scale: 3, orientation: .right)

        return croppedImage
    }


    func cropImageTo1x1(cgImage: CGImage) -> UIImage {
        // 元の画像のサイズを取得
        let originalWidth = CGFloat(cgImage.width)
        let originalHeight = CGFloat(cgImage.height)

        // 切り抜き後のサイズを計算
        let cropWidth = originalHeight

        // 切り抜き領域のY座標を計算 (中央から切り抜く場合)
        let cropX = (originalWidth - cropWidth) / 2.0
        let cropRect = CGRect(x: cropX, y: 0, width: cropWidth, height: cropWidth)

        // CGImageを用いて切り抜き
        guard let croppedCGImage = cgImage.cropping(to: cropRect) else {
            return UIImage()
        }

        // 切り抜いたCGImageからUIImageを作成
        let croppedImage = UIImage(cgImage: croppedCGImage, scale: 3, orientation: .right)

        return croppedImage
    }
}
