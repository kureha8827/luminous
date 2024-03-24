//
//  StopWatch.swift
//  luminous
//
//  Created by kureha8827 on 2024/03/22.
//

import Foundation

class StopWatch: ObservableObject {
    @Published var elapsedTime : Double = 0
    private var timer = Timer()

    func start() {
        guard !timer.isValid else { return }
        self.elapsedTime = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            self.elapsedTime += 0.01
        }
    }

    func stop() {
        timer.invalidate()
    }
}
