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
        VStack {
            let afterDir = "file://" + NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/before/"   // あとからafterに変える
            let path = URL(string: afterDir)!
            let tempFileURL = path.appendingPathComponent("temp_\(cam.outputFrameCount == 30 ? 1 : cam.outputFrameCount + 1).jpg")
            Image(uiImage: UIImage(path: tempFileURL) ?? UIImage())
                .rotationEffect(.degrees(90))
                .frame(width: 100, height: 100)
        }
        .onAppear() {
            DispatchQueue.global().async {
                cam.session.startRunning()
            }
            cam.camSetting()
        }
    }
}
