//
//  AnimationController.swift
//  luminous
//
//  Created by kureha8827 on 2024/03/15.
//

import SwiftUI
import SpriteKit

class AnimationController {
    @ViewBuilder
    func babbleParticle() -> some View {
        GeometryReader {
            SpriteView(scene: BabbleParticleView(size: $0.size), options: [.allowsTransparency])
        }
    }
}

class BabbleParticleView: SKScene {
    override func didMove(to view: SKView) {
        let emitterNode = SKEmitterNode(fileNamed: "BabbleParticle")!
        emitterNode.numParticlesToEmit = 150
        backgroundColor = .clear
        anchorPoint = CGPoint(x: 0.5, y: 0)
        addChild(emitterNode)
    }
}
