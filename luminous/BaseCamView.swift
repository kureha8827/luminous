import SwiftUI
import AVFoundation

class BaseCamView: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @AppStorage("last_pic") var picData = Data(count: 0)
    @Published var isCameraBack: Bool = true
    @Published var canUse: Bool = false                 // 不具合が起こらないように故意的にカメラの使用を制限する
    @Published var session = AVCaptureSession()
    @Published var output = AVCaptureVideoDataOutput()
    @Published var photoSettings = AVCapturePhotoSettings()
    @Published var outputFrameCount: Int = 1
    @Published var uiImage: UIImage = UIImage()
    @Published var currentFilter: Int? = nil
    @Published var filterNum: Int = 10

    var inputDevice: AVCaptureDeviceInput!
    
    // lazyを用いると最初に呼び出した時のみ実行される
    // lazyを用いる理由: セットアップの処理が重く、使われるまでは生成したくないため
    func captureSession() {
        
        // 設定変更を開始
        self.session.beginConfiguration()
        self.session.sessionPreset = .photo   // 解像度の設定
        
        // カメラデバイスのプロパティ設定と、プロパティの条件を満たしたカメラデバイスの取得
        // AVCaptureDeviceInputを生成, デバイス取得時に機種によりエラーが起こる可能性があることを想定する
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            self.inputDevice = try? AVCaptureDeviceInput(device: device)
        }

        // インプット元をセッションに追加
        if self.session.canAddInput(self.inputDevice) {
            self.session.addInput(self.inputDevice)
        }
        
        self.session.commitConfiguration()
        
        self.output.setSampleBufferDelegate(self, queue: DispatchQueue.main)

        if self.session.canAddOutput(self.output) {
            self.session.addOutput(self.output)
        }

        // 画質、アス比等の設定
        setting()

        DispatchQueue.global().async {
            self.session.startRunning()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {self.canUse = true}

    }
    
    func changeCam() {
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.2)) {
                self.canUse = false
            }
        }
        DispatchQueue.global(qos: .userInteractive).async {
            // 設定変更を開始
            self.session.beginConfiguration()
            
            var device: AVCaptureDevice?
            
            if self.isCameraBack {
                device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
            } else {
                device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
            }
            
            self.inputDevice = try? AVCaptureDeviceInput(device: device!)
            
            // すでにセッションにあるインプットを削除
            for input in self.session.inputs {
                self.session.removeInput(input as AVCaptureInput)
            }
            
            if self.session.canAddInput(self.inputDevice) {
                self.session.addInput(self.inputDevice)
            }
            
            self.session.commitConfiguration()
            
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.2)) {
                    self.canUse = true
                }
            }
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        // 撮影データを生成
        // CIImageに変換(使いやすくするため)
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        var ciImage = CIImage(cvImageBuffer: imageBuffer)

        // TODO:  何らかの画像処理を行う
        ciImage = self.filter(ciImage)

        // CGImageに変換(画面の向き情報を保持するため)
        let cgImage: CGImage? = CIContext().createCGImage(ciImage, from: ciImage.extent)

        // UIImageに変換
        if let img = cgImage {
            self.uiImage = UIImage(cgImage: img, scale: 3, orientation: .right)
        } else { return }
    }
    
    func setting() {
        //        self.photoSettings.photoQualityPrioritization = .quality
        self.session.sessionPreset = .hd1920x1080
    }

    func takePhotoPrevTransition(_ isTaked: Bool) {
        // TODO:  何らかの処理
        if isTaked {
            UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
        }

        DispatchQueue.global().async {
            self.session.startRunning()
        }
        canUse = true
    }

    func filter(_ img: CIImage) -> CIImage {
        // TODO: フィルタ加工
        if currentFilter == 0 {
            // original
        } else if currentFilter == 1 {
            // filter1
        }   // ...フィルタの数だけ追加

        return img
    }
}

class Filter: ObservableObject {
    @Published var filterSize: [Double] = Array(repeating: 0.0, count: 10)
}
