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
//        SpriteView(scene: BabbleParticleView(size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)), options: [.allowsTransparency, .shouldCullNonVisibleNodes])
        SpriteView(scene: BabbleParticleView(size:
                                                CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)),
                   options: [.allowsTransparency, .shouldCullNonVisibleNodes])
        .edgesIgnoringSafeArea(.all)
        .zIndex(3)
        .contentShape(.interaction, Rectangle().scale(0))
    }
}

class BabbleParticleView: SKScene {
    @ObservedObject private var timer = StopWatch()
    override func didMove(to view: SKView) {
        let emitterNode = SKEmitterNode(fileNamed: "BabbleParticle")!
        emitterNode.numParticlesToEmit = 150
        backgroundColor = .clear
        anchorPoint = CGPoint(x: 0.5, y: 0)
        timer.start()
        addChild(emitterNode)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2){
            emitterNode.removeFromParent()
        }
    }
}


//.contentShape(.interaction, Rectangle().scale(0))
