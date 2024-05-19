//
//  GenericParts.swift
//  luminous
//
//  Created by kureha8827 on 2024/03/16.
//

import SwiftUI

/* ロゴ */

struct TitleView: View {
    var scale: CGFloat = 1
    var body: some View {
        HStack {
            Text("LUMIN").offset(x: 10)
            Image(systemName: "scope").font(.system(size: 36 * scale))
            Text("US").offset(x: -7)
        }
        .font(.system(size: 40 * scale))
            .italic()
            .foregroundColor(.lightPurple)
            .tracking(6)
    }
}

/* ButtonStyle */

struct OpacityButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.opacity(1)
    }
}



/* Slider */

struct MainSlider: UIViewRepresentable {

    // UIKitでのイベントをSwiftUIで管理するためのクラス
    class Coordinator: NSObject {
        var parent: MainSlider
        init(parent: MainSlider) {
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
    func makeCoordinator() -> MainSlider.Coordinator {
        Coordinator(parent: self)
    }
}

// リサイズができるように拡張
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

/* その他 */

class ViewSwitcher: ObservableObject {
    @Published var value: Int = 0
    @Published var beforeValue: Int = 0
    @Published var isShowMainView: Bool = false
    @Published var isExistMainView: Bool = false
    @Published var deleteSetupView: Bool = false
    @Published var fromBeginViewToMainView: UIImage?
    @Published var isVisibleTabBar: Bool = true
    @Published var isShowFilterView: Double = 0.0
}
