//
//  extension_UIImage.swift
//  luminous
//
//  Created by kureha8827 on 2024/05/22.
//

import SwiftUI

extension UIImage {
    func resized(toWidth width: CGFloat, using rendererFormat: UIGraphicsImageRendererFormat = .default()) -> UIImage? {
        let scale = width / self.size.width
        let height = self.size.height * scale
        let size = CGSize(width: width, height: height)
        let renderer = UIGraphicsImageRenderer(size: size, format: rendererFormat)
        return renderer.image { (context) in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
