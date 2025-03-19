//
//  Shutter.swift
//  luminous
//
//  Created by kureha8827 on 2024/08/02.
//

import SwiftUI
import AVKit
import AsyncAlgorithms

@MainActor
struct Shutter: Sendable {
    let camFmt = CameraFormatter()
    @State private var time: Double = 0

    func takePhoto(_ cam: BaseCamera, _ vs: ViewSwitcher) async {
        cam.canUse = false

        // タイマーの秒数
        cam.time = switch cam.optionSelect[3] {
        case 0: 0
        case 1: 3
        case 2: 10
        default: 0
        }

        let timer = AsyncTimerSequence(
            interval: .seconds(0.01),
            clock: .continuous
        )

        await Task {
            cam.isTimerValid = true
            for await _ in timer {
                cam.time -= 0.01
                cam.time = round(cam.time * 100) / 100    // 小数第2位まで表示
                if cam.time <= 0 {
                    break
                }
            }
        }.value

        cam.isTimerValid = false
        //        timerTask.cancel()



        if cam.optionSelect[2] == 0 {
            Task {
                await Task {
                    cam.session.stopRunning()
                }.value
                await Task { @MainActor in
                    await camFmt.uiImageRotation(&cam.uiImage)
                }.value
                //                try? await Task.sleep(for: .seconds(1))
                await Task { @MainActor in
                    vs.value = 20
                }.value
            }
        } else {    // フラッシュオン
            guard cam.device!.hasTorch else { return }
            try? cam.device!.lockForConfiguration()
            if (cam.device!.torchMode == .off) {
                try? cam.device!.setTorchModeOn(level: 1.0)
            }
            cam.device!.unlockForConfiguration()
            Task {
                try? await Task.sleep(for: .seconds(1.3))
                try? cam.device!.lockForConfiguration()
                cam.device!.torchMode = .off
                cam.device!.unlockForConfiguration()

                try? await Task.sleep(for: .seconds(0.2))
                try? cam.device!.lockForConfiguration()
                try? cam.device!.setTorchModeOn(level: 1.0)
                cam.device!.unlockForConfiguration()

                try? await Task.sleep(for: .seconds(0.1))
                var ciImage: CIImage

                if let img = cam.uiImage.cgImage {
                    ciImage = CIImage(cgImage: img)
                } else { return }

                // 画面の向きを考慮した画像の取得
                ciImage = ciImage.transformed(by: CGAffineTransform(rotationAngle: round(-90.0*powl(Double(UIDevice.current.orientation.rawValue)-3.5+1.0/(4.0*Double(UIDevice.current.orientation.rawValue)-14.0), -11))*Double.pi/180.0))
                let context = CIContext()
                let cgImage: CGImage? = context.createCGImage(ciImage, from: ciImage.extent)

                // UIImageに変換
                Task { @MainActor in
                    if let img = cgImage {
                        cam.uiImage = UIImage(cgImage: img, scale: 3, orientation: .right)
                    }
                }


                cam.session.stopRunning()
                Task { @MainActor in
                    vs.value = 20
                }

                try? cam.device!.lockForConfiguration()
                cam.device!.torchMode = .off
                cam.device!.unlockForConfiguration()
            }
        }
    }


    struct VolumeButtonShutter: UIViewRepresentable {
        @EnvironmentObject var cam: BaseCamera
        @EnvironmentObject var vs: ViewSwitcher
        @State private var eventInteraction: AVCaptureEventInteraction?
        let shutter = Shutter()

        func makeUIView(context: Context) -> UIView {
            let viewController = UIViewController()
            let interaction = AVCaptureEventInteraction { event in
                if event.phase == .began {
                    Task {
                        await shutter.takePhoto(cam, vs)
                    }
                }
            }
            viewController.view.addInteraction(interaction)
            return viewController.view
        }

        func updateUIView(_ uiView: UIView, context: Context) {
        }
    }
}
