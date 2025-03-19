//
//  AnimationController.swift
//  luminous
//
//  Created by kureha8827 on 2024/03/15.
//

import SwiftUI
import SpriteKit
struct BabbleParticle: View {
    var zIndex: Double
    var body: some View {
        ZStack {
            SpriteView(scene: BabbleParticleView(size:
                CGSize(
                    width: DisplayInfo.width,
                    height: DisplayInfo.height
                )),
                options: [.allowsTransparency, .shouldCullNonVisibleNodes])
            .ignoresSafeArea()
        }
        .zIndex(zIndex)
    }
}

class BabbleParticleView: SKScene, ObservableObject {
    @Published var isChanged: Bool = false
    override func didMove(to view: SKView) {
        Task {
            let emitterNode = SKEmitterNode(fileNamed: "BabbleParticle")!
            emitterNode.numParticlesToEmit = 150
            backgroundColor = .clear
            anchorPoint = CGPoint(x: 0.5, y: 0)
            addChild(emitterNode)
            try? await Task.sleep(for: .seconds(1.5))
            emitterNode.removeFromParent()
        }
    }
}
