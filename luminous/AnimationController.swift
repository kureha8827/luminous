//
//  AnimationController.swift
//  luminous
//
//  Created by kureha8827 on 2024/03/15.
//

import SwiftUI
import SpriteKit

class AnimationController {
    @ObservedObject var bpv = BabbleParticleView()
    @ViewBuilder
    func babbleParticle(zIndex n: Double) -> some View {
//        SpriteView(scene: BabbleParticleView(size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)), options: [.allowsTransparency, .shouldCullNonVisibleNodes])
        ZStack {
            SpriteView(scene: BabbleParticleView(size:
                                                    CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)),
                       options: [.allowsTransparency, .shouldCullNonVisibleNodes])

                .ignoresSafeArea()
        }.zIndex(bpv.isChanged ? 0 : n)
        let _ = print("\(bpv.isChanged)")
    }
}

class BabbleParticleView: SKScene, ObservableObject {
    @Published var isChanged: Bool = false
    @ObservedObject private var timer = StopWatch()
    override func didMove(to view: SKView) {
        let emitterNode = SKEmitterNode(fileNamed: "BabbleParticle")!
        emitterNode.numParticlesToEmit = 150
        backgroundColor = .clear
        anchorPoint = CGPoint(x: 0.5, y: 0)
        timer.start()
        addChild(emitterNode)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            emitterNode.removeFromParent()
            self.isChanged = true
            print("\n\n\n\n\n\n\n\n\ninBPV: \(self.isChanged)\n\n\n\n\n\n\n\n\n")
        }
    }
}


//.contentShape(.interaction, Rectangle().scale(0))
