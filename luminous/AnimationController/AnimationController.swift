//
//  AnimationController.swift
//  luminous
//
//  Created by kureha8827 on 2024/03/15.
//

import SwiftUI
import SpriteKit
struct BabbleParticle: View {
    @State private var isChanged: Bool = false
    var zIndex: Double
    var body: some View {
        ZStack {
            SpriteView(scene: BabbleParticleView(size:
                CGSize(
                    width: DisplayInfo.width,
                    height: DisplayInfo.height
                )),
                options: [.allowsTransparency, .shouldCullNonVisibleNodes])
            .onAppear() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.isChanged = true
                }
            }
            .ignoresSafeArea()
        }
        .zIndex(self.isChanged ? 0 : zIndex)
    }
}

class BabbleParticleView: SKScene, ObservableObject {
    @Published var isChanged: Bool = false
    override func didMove(to view: SKView) {
        let emitterNode = SKEmitterNode(fileNamed: "BabbleParticle")!
        emitterNode.numParticlesToEmit = 150
        backgroundColor = .clear
        anchorPoint = CGPoint(x: 0.5, y: 0)
        addChild(emitterNode)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            emitterNode.removeFromParent()
        }
    }
}
