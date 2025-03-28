//
//  PresenterView.swift
//  luminous
//
//  Created by kureha8827 on 2024/04/24.
//

import SwiftUI

struct PresenterView: View {
    @EnvironmentObject var vs: ViewSwitcher
    @State private var isShowMainView: Bool = false
    var body: some View {
        ZStack {
            switch (vs.value) {
            case 10:
                MainView()
            case 20:
                TakePhotoPrevView()
            default:
                BeginView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
