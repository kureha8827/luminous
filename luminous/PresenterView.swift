//
//  PresenterView.swift
//  luminous
//
//  Created by kureha8827 on 2024/04/24.
//

import SwiftUI

struct PresenterView: View {
    @EnvironmentObject var cam: BaseCamView
    @State private var isShowMainView: Bool = false
    @EnvironmentObject var viewSwitcher: ViewSwitcher
    var body: some View {
        switch (viewSwitcher.value) {
        case 10:
            MainView()
        case 20:
            TakePhotoPrev()
        default:
            BeginView()
        }
    }
}
