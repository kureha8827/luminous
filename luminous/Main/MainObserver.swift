//
//  MainObserver.swift
//  luminous
//
//  Created by kureha8827 on 2024/07/01.
//

import Foundation

class MainObserver: @unchecked Sendable, ObservableObject {
    @Published var selectedTag = 1
    @Published var isShowTabBar = true
}
