//
//  PresenterView.swift
//  luminous
//
//  Created by kureha8827 on 2024/04/24.
//

import SwiftUI

struct PresenterView: View {
    @EnvironmentObject var cam: BaseCamView
    @EnvironmentObject var viewSwitcher: ViewSwitcher
    @State private var isShowMainView: Bool = false
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
