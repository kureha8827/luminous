//
//  OptionClass.swift
//  luminous
//
//  Created by kureha8827 on 2024/06/21.
//

import SwiftUI

class OptionClass {

    func main(_ cam: BaseCamera, _ cur: Int) {
        switch cur {
        case 0: quality(cam)
        case 1: aspectratio(cam)
        case 2: flash(cam)
        case 3: timer(cam)
        default: return
        }
        cam.captureSession()
    }


    func imageName(_ cur: Int) -> String {
        return switch cur {
        case 0: "quality"
        case 1: "aspectratio"
        case 2: "flash"
        case 3: "timer"
        default: ""
        }
    }


    // イメージボタン
    struct ImageView: View {
        @EnvironmentObject var cam: BaseCamera
        var cur: Int
        init(_ cur: Int) {
            self.cur = cur
        }
        var body: some View {
            switch cur {
            case 0: 
                ZStack {
                    Image(systemName: "square")
                        .font(.system(size: 36))
                    switch cam.optionSelect[0] {
                    case 0: Text("HD")
                            .font(.system(size: 16))
                    case 1: Text("4K")
                            .font(.system(size: 16))
                    case 2: Text("SD")
                            .font(.system(size: 16))
                    default: EmptyView()
                    }
                }
                .tint(.white)

            case 1: 
                switch cam.optionSelect[1] {
                case 0: Text("9:16")
                        .font(.system(size: 18))
                        .tracking(2)
                        .tint(.white)
                case 1: Text("3:4")
                        .font(.system(size: 18))
                        .tracking(2)
                        .tint(.white)
                case 2: Text("1:1")
                        .font(.system(size: 18))
                        .tracking(2)
                        .tint(.white)
                default: EmptyView()
            }

            case 2: 
                switch cam.optionSelect[2] {
                case 0: Image(systemName: "bolt.slash")
                        .font(.system(size: 32))
                        .tint(.white)
                case 1: Image(systemName: "bolt")
                        .font(.system(size: 32))
                        .tint(.white)
                default: EmptyView()
                }

            case 3: Image(systemName: "timer")
                    .font(.system(size: 32))
                    .tint(.white)
            default: EmptyView()
            }
        }
    }


    // 画質
    func quality(_ cam: BaseCamera) {
        // HD / SD / 4K の3種類
        // ボタンを押すごとに0, 1, 2, 0, ...と循環
        if (cam.optionSelect[0] < 2) {
            cam.optionSelect[0] += 1
        } else {
            cam.optionSelect[0] = 0
        }
        print("quality: \(cam.optionSelect[0])")
    }


    // アスペクト比
    func aspectratio(_ cam: BaseCamera) {
        // 16:9 / 4:3 / 1:1 の3種類
        // ボタンを押すごとに0, 1, 2, 0, ...と循環
        if (cam.optionSelect[1] < 2) {
            cam.optionSelect[1] += 1
        } else {
            cam.optionSelect[1] = 0
        }
        print("aspectratio: \(cam.optionSelect[1])")
    }


    // フラッシュ
    func flash(_ cam: BaseCamera) {
        // ON / OFF の2種類
        // ボタンを押すごとに0, 1, 0, ...と循環
        if (cam.optionSelect[2] < 1) {
            cam.optionSelect[2] += 1
        } else {
            cam.optionSelect[2] = 0
        }
        print("flash: \(cam.optionSelect[2])")
    }


    // タイマー
    func timer(_ cam: BaseCamera) {
        print("timer")
    }
}
