//
//  OptionClass.swift
//  luminous
//
//  Created by kureha8827 on 2024/06/21.
//

import SwiftUI
@MainActor
final class OptionClass: Sendable {

    func main(_ cam: BaseCamera, _ cur: Int) {
        Task {
            cam.canUse = false
            cam.isShowCamera = false
            
            switch cur {
            case 0: quality(cam)
            case 1: aspectratio(cam)
            case 2: flash(cam)
            case 3: timer(cam)
            default: return
            }

            await cam.startSession()
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
                .tint(.white)   // ここで.foregroundStyle(.white)を使用するとグレーアウトに対応できなくなる

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

            case 3: 
                switch cam.optionSelect[3] {
                case 0:
                    ZStack {
                        Image(systemName: "timer")
                            .font(.system(size: 32))
                            .tint(.white)
                        Text("off")
                            .font(.system(size: 16))
                            .tint(.white)
                            .offset(x: 6, y: 6)
                            .shadow(color: .black, radius: 1, x: 1, y: 1)
                    }
                case 1:
                    ZStack {
                        Image(systemName: "timer")
                            .font(.system(size: 32))
                            .tint(.white)
                        Text("3s")
                            .font(.system(size: 16))
                            .tint(.white)
                            .offset(x: 6, y: 6)
                            .shadow(color: .black, radius: 1, x: 1, y: 1)
                    }
                case 2:
                    ZStack {
                        Image(systemName: "timer")
                            .font(.system(size: 32))
                            .tint(.white)
                        Text("10s")
                            .font(.system(size: 16))
                            .tint(.white)
                            .offset(x: 6, y: 6)
                            .shadow(color: .black, radius: 1, x: 1, y: 1)
                    }
                default: EmptyView()
                }
            default: EmptyView()
            }
        }
    }


    // 画質
    func quality(_ cam: BaseCamera) {
        // HD / 4K / SD の3種類
        // ボタンを押すごとに0, 1, 2, 0, ...と循環
        if (cam.optionSelect[0] < 2) {
            cam.optionSelect[0] += 1
        } else {
            cam.optionSelect[0] = 0
        }
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
    }


    // フラッシュ
    func flash(_ cam: BaseCamera) {
        // OFF / ON の2種類
        // ボタンを押すごとに0, 1, 0, ...と循環
        if (cam.optionSelect[2] < 1) {
            cam.optionSelect[2] += 1
        } else {
            cam.optionSelect[2] = 0
        }
    }


    // タイマー
    func timer(_ cam: BaseCamera) {
        // OFF / 3s / 10s の3種類
        // ボタンを押すごとに0, 1, 2, 0, ...と循環
        if (cam.optionSelect[3] < 2) {
            cam.optionSelect[3] += 1
        } else {
            cam.optionSelect[3] = 0
        }
    }
}
