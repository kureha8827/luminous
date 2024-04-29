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
                CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)),
                options: [.allowsTransparency, .shouldCullNonVisibleNodes])
            .onAppear() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.isChanged = true
                    print("\n\n\n\ngcd: \(self.isChanged)\n\n\n\n")
                }
            }
            .ignoresSafeArea()
        }
        .zIndex(self.isChanged ? 0 : zIndex)
        let _ = print("\(self.isChanged)")
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
        }
    }
}


//.contentShape(.interaction, Rectangle().scale(0))
