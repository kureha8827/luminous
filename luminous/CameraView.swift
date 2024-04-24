//
//  CameraView.swift
//  luminous
//
//  Created by kureha8827 on 2024/03/31.
//

import SwiftUI

struct CameraView: View {
    @EnvironmentObject var cam: BaseCamView
    var body: some View {
        ZStack {
            Image(uiImage: cam.uiImage)
        }
        .onAppear() {
            DispatchQueue.global().async {
                cam.session.startRunning()
            }
            cam.camSetting()
        }
    }
}
