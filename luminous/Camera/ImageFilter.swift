//
//  ImageFilter.swift
//  luminous
//
//  Created by kureha8827 on 2024/05/22.
//

import SwiftUI

class ImageFilter: ObservableObject {
    @Published var filterSize = Array(repeating: Float(0), count: 10)
    let filterNames = CIFilter.filterNames(inCategory: kCICategoryBuiltIn) as [String]
    func type1(_ img: CIImage) -> CIImage {
        // TODO: フィルタ処理
        //        print("\(filterNames)")
        return img
    }
}
