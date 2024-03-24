import SwiftUI
import AVFoundation

struct CameraView: UIViewRepresentable {  
    @Binding var isCameraBack: Bool

    // UIViewRepesentableはSwiftUIでUIKitを使うためのプロトコル
    func makeUIView(context: Context) -> UIView { BaseCameraView() }
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

class BaseCameraView: UIView {
    var isPresented: Bool = true
//    init(isPresented: Bool) {
//        self.isPresented = isPresented
//    }

    override func layoutSubviews() {
        super.layoutSubviews()
        _ = initCaptureSession
        (layer.sublayers?.first as? AVCaptureVideoPreviewLayer)?.frame = frame

    }

    lazy var initCaptureSession: Void = {   // lazyを用いる理由: セットアップの処理が重く、使われるまでは生成したくないため
        // カメラデバイスのプロパティ設定と、プロパティの条件を満たしたカメラデバイスの取得
        guard let device = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: .back  // 背面カメラ
        )
        .devices.first(where: { $0.position == .back }),
        let deviceInput = try? AVCaptureDeviceInput(device: device) else { return } // AVCaptureDeviceInputを生成, デバイス取得時に機種によりエラーが起こる可能性があることを想定する
        
        let session = AVCaptureSession()    // セッションとは処理の開始から終了までを指す
        
        if session.canAddInput(deviceInput) {
            session.addInput(deviceInput)
            // avInput = deviceInput
        }
        
        let photoOutput = AVCapturePhotoOutput()    // AVCaptureDeviceInputを生成, 単に出力するだけなのでエラーは起きないものと考える
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            // avOutput = photoOutput
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
//        previewLayer.frame = photoView.bounds
        previewLayer.videoGravity = .resizeAspectFill
//        previewLayer.connection?.videoOrientation = .landscapeRight
//        layer.insertSublayer(previewLayer, at: 100)
        session.sessionPreset = AVCaptureSession.Preset.photo
        layer.addSublayer(previewLayer)
        
        DispatchQueue.global().async {
            session.startRunning()
        }
    }()
}
