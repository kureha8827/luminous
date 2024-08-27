//
//  Editor.swift
//  luminous
//
//  Created by kureha8827 on 2024/06/30.
//

import SwiftUI

/*      TODO: uiImageを配列にして全ての加工した段階における画像を保持する
    現在表示している画像を表すInt型変数を追加する
    一つの加工が完了すると同時に上記の変数を+1する
    フィルタ、調整加工は現在の画像を元に1つ先の要素に代入する
*/
final class Editor: @unchecked Sendable, ObservableObject {
    @Published var uiImage: [UIImage?] = []
    @Published var uiImageNode: Int = 0
    @Published var isEditing = false

    // 調整機能
    @Published var currentAdjuster: Int = 0     //調整Viewでどの効果を選択するかのパラメータ
    @Published var adjusterSize: [Int]
    private var adjuster: ImageAdjuster

    // フィルタ機能
    @Published var currentFilter: Int = 0       // フィルタViewでどの効果を選択するかのパラメータ
    @Published var filterSize: [Int]
    private var filter: ImageFilter

    // 顔加工機能
    @Published var currentBeauty: [Int] = [-1, 0, 0]
    //調整Viewでどの効果を選択するかのパラメータ
    @Published var beautySize: [[[Int]]] = []
    private var beauty: ImageBeauty

    init() {
//        context = CIContext(
//            mtlDevice: MTLCreateSystemDefaultDevice()!
//        )
        adjuster = ImageAdjuster()
        filter = ImageFilter(size: Array(repeating: 0, count: ConstStruct.filterNum))
        beauty = ImageBeauty()
        adjusterSize = Array(repeating: 0, count: ConstStruct.adjusterNum)
        filterSize = Array(repeating: 0, count: ConstStruct.filterNum)

        beautySize = Beauty.kinds.map {
            $0.map {
                Array(repeating: 0, count: $0.count)
            }
        }
    }


    func edit() {
        adjuster.size = adjusterSize
        filter.size = filterSize

        var ciImage: CIImage

        if let img = uiImage[uiImageNode - 1]?.cgImage {
            ciImage = CIImage(cgImage: img)
        } else {
            return
        }
        
        // 画像調整処理
        adjuster.output(&ciImage)
        // フィルタ処理
        filter.output(&ciImage, currentFilter)

        let context = CIContext()
        let cgImage: CGImage? = context.createCGImage(ciImage, from: ciImage.extent)

        // UIImageに変換
        Task { @MainActor in
            if let img = cgImage {
                self.uiImage[uiImageNode] = UIImage(cgImage: img)
            }
        }
    }


    func download() {
        // TODO:  何らかの処理
        guard let img = uiImage[uiImageNode] else { return }
        UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
    }
}
