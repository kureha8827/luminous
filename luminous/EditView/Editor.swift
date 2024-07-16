//
//  Editor.swift
//  luminous
//
//  Created by kureha8827 on 2024/06/30.
//

import SwiftUI

class Editor: ObservableObject {
    @Published var uiImage: UIImage?
    @Published var isEditing = false
    // 調整機能
    @Published var currentAdjuster: Int = 0     // 調整Viewでどの効果を選択するかのパラメータ
    @Published var adjusterSize: [Float]
    private var adjuster: ImageAdjuster

    // フィルタ機能
    @Published var currentFilter: Int = 0       // フィルタViewでどの効果を選択するかのパラメータ
    @Published var filterSize: [Float]
    private var filter: ImageFilter

    init() {
//        context = CIContext(
//            mtlDevice: MTLCreateSystemDefaultDevice()!
//        )
        adjuster = ImageAdjuster()
        adjusterSize = Array(repeating: Float(0), count: ConstStruct.adjusterNum)
        filter = ImageFilter(size: Array(repeating: Float(0), count: ConstStruct.filterNum))
        filterSize = Array(repeating: Float(0), count: ConstStruct.filterNum)
    }


    func download() {
        // TODO:  何らかの処理
        guard let img = uiImage else { return }
        UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
    }
}
