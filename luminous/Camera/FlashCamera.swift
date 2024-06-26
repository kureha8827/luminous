import SwiftUI
import AVKit
import AVFoundation

class FlashCamera: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    // フラッシュ用
    @Published var session = AVCaptureSession()
    @Published var output = AVCapturePhotoOutput()
    private var device: AVCaptureDevice?
    let deviceTypes: [AVCaptureDevice.DeviceType] = [.builtInTripleCamera, .builtInDualWideCamera, .builtInDualCamera, .builtInWideAngleCamera]
    var inputDevice: AVCaptureDeviceInput!

    
    func captureSession() {
        print("flashCaptureSession")

        // 設定変更を開始
        session.beginConfiguration()

        // カメラデバイスのプロパティ設定と、プロパティの条件を満たしたカメラデバイスの取得
        // AVCaptureDeviceInputを生成, デバイス取得時に機種によりエラーが起こる可能性があることを想定する
        device = AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes, mediaType: .video, position: .back).devices.first
        if let device = self.device {
            inputDevice = try? AVCaptureDeviceInput(device: device)
        }

        // インプット元をセッションに追加
        if session.canAddInput(inputDevice) {
            session.addInput(inputDevice)
        }

        session.commitConfiguration()

        // 写真撮影のための出力の設定
        if session.canAddOutput(output) {
            session.addOutput(output)
        }

        DispatchQueue.global().async {
            self.session.startRunning()
        }
    }



    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        print("1. photoOutput")
        if let error = error {
            print("Error capturing photo: \(error)")
            return
        }
        print("2. photoOutput")
    }



    func takePhoto() {
//        session.stopRunning()
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .on
        output.capturePhoto(with: settings, delegate:  self)
    }
}
