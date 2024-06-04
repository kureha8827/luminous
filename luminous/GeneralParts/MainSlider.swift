//
//  MainSlider.swift
//  luminous
//
//  Created by kureha8827 on 2024/05/22.
//

import SwiftUI

/* Slider */

struct PositiveSlider: UIViewRepresentable {

    // UIKitでのイベントをSwiftUIで管理するためのクラス
    class Coordinator: NSObject {
        var parent: PositiveSlider
        init(parent: PositiveSlider) {
            self.parent = parent
        }
        @objc func valueChanged(_ sender: UISlider) {
            parent.value = Float(sender.value)
        }
    }

    @Binding var value: Float
    var width: CGFloat = 0

    func makeUIView(context: Context) -> UISlider {
        class TapSlider: UISlider {
            override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
                let tapPoint = touch.location(in: self)
                let fraction = Float(tapPoint.x / bounds.width)
                let newValue = (maximumValue - minimumValue) * fraction + minimumValue
                if newValue != self.value {
                    self.value = newValue
                    sendActions(for: .valueChanged)
                }
                return super.beginTracking(touch, with: event)
            }
        }
        let slider = TapSlider(frame: .zero)
        print("\(width)")
        if let minTrackImage = UIImage(named: "minSlider")?.resized(toWidth: self.width) {
            slider.setMinimumTrackImage(minTrackImage, for: .normal)
        }
        if let maxTrackImage = UIImage(named: "maxSlider")?.resized(toWidth: self.width) {
            slider.setMaximumTrackImage(maxTrackImage, for: .normal)
        }

        slider.value = Float(self.value) // Sliderの値に初期値を代入
        slider.addTarget(
            context.coordinator,
            action: #selector(Coordinator.valueChanged(_:)),
            for: .valueChanged
        )


        // valueが取る最小値, 最大値
        slider.minimumValue = 0
        slider.maximumValue = 100

        return slider
    }

    func updateUIView(_ uiView: UISlider, context: Context) {
        DispatchQueue.main.async {
            uiView.value = Float(self.value)
        }
    }

    // 最初に呼び出される
    func makeCoordinator() -> PositiveSlider.Coordinator {
        Coordinator(parent: self)
    }
}


struct NegativeSlider: UIViewRepresentable {

    // UIKitでのイベントをSwiftUIで管理するためのクラス
    class Coordinator: NSObject {
        var parent: NegativeSlider
        init(parent: NegativeSlider) {
            self.parent = parent
        }
        @objc func valueChanged(_ sender: UISlider) {
            parent.value = Float(sender.value)
        }
    }

    @Binding var value: Float
    var width: CGFloat = 0

    func makeUIView(context: Context) -> UISlider {
        class TapSlider: UISlider {
            override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
                let tapPoint = touch.location(in: self)
                let fraction = Float(tapPoint.x / bounds.width)
                let newValue = (maximumValue - minimumValue) * fraction + minimumValue
                if newValue != self.value {
                    self.value = newValue
                    sendActions(for: .valueChanged)
                }
                return super.beginTracking(touch, with: event)
            }
        }
        let slider = TapSlider(frame: .zero)
        print("\(width)")
        if let minTrackImage = UIImage(named: "minSlider")?.resized(toWidth: self.width) {
            slider.setMinimumTrackImage(minTrackImage, for: .normal)
        }
        if let maxTrackImage = UIImage(named: "maxSlider")?.resized(toWidth: self.width) {
            slider.setMaximumTrackImage(maxTrackImage, for: .normal)
        }

        slider.value = Float(self.value) // Sliderの値に初期値を代入
        slider.addTarget(
            context.coordinator,
            action: #selector(Coordinator.valueChanged(_:)),
            for: .valueChanged
        )


        // valueが取る最小値, 最大値
        slider.minimumValue = -100
        slider.maximumValue = 100

        return slider
    }

    func updateUIView(_ uiView: UISlider, context: Context) {
        DispatchQueue.main.async {
            uiView.value = Float(self.value)
        }
    }

    // 最初に呼び出される
    func makeCoordinator() -> NegativeSlider.Coordinator {
        Coordinator(parent: self)
    }
}
