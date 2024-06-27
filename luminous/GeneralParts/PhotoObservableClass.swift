//
//  PhotoObservableClass.swift
//  luminous
//
//  Created by kureha8827 on 2024/06/26.
//

import Foundation

class PhotoObservableClass: ObservableObject {
    @Published var isSwipe: Bool = false
    @Published var isEditing: Double = 0.0
    @Published var isShowFilter: Double = 0.0
    @Published var isShowAdjuster: Double = 0.0
}
