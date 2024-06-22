//
//  OptionClass.swift
//  luminous
//
//  Created by kureha8827 on 2024/06/21.
//

import SwiftUI

class OptionClass {
    func main(_ cur: Int) {
        switch cur {
        case 0: quality()
        case 1: aspectratio()
        case 2: flash()
        case 3: timer()
        default: return
        }
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
            if (cur == 0) {
                ZStack {
                    Image(systemName: "square")
                        .font(.system(size: 36))
                    Text("HD")
                        .font(.system(size: 16))
                }
                .tint(.white)
            } else if (cur == 1) {
                Text("16:9")
                    .font(.system(size: 18))
                    .tracking(2)
                    .tint(.white)
            } else if (cur == 2) {
                Image(systemName: "bolt")
                    .font(.system(size: 32))
                    .tint(.white)
            } else if (cur == 3) {
                Image(systemName: "timer")
                    .font(.system(size: 32))
                    .tint(.white)
            }
        }
    }


    // 画質
    func quality() {
        print("quality")
    }


    // アスペクト比
    func aspectratio() {
        print("aspectratio")
    }


    // フラッシュ
    func flash() {
        print("flash")
    }


    // タイマー
    func timer() {
        print("timer")
    }
}
