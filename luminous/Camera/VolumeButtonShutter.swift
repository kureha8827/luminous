//
//  VolumeButton.swift
//  luminous
//
//  Created by kureha8827 on 2024/06/20.
//

import SwiftUI
import AVKit

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
