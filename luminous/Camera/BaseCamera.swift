import SwiftUI
import AVFoundation

class BaseCamera: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @AppStorage("last_pic") var picData = Data(count: 0)
    @Published var isCameraBack: Bool = true
    @Published var canUse: Bool = false                 // 不具合が起こらないように故意的にカメラの使用を制限する
    @Published var session = AVCaptureSession()
    @Published var output = AVCaptureVideoDataOutput()
    @Published var photoSettings = AVCapturePhotoSettings()
    @Published var outputFrameCount: Int = 1
    @Published var uiImage: UIImage = UIImage()

    @Published var currentAdjuster: Int = 0 // 調整Viewでどの効果を選択するかのパラメータ
    @Published var imgAdjusterNum: Int = 11
    @Published var adjusterSize = Array(repeating: Float(0), count: 11)
    private var adjuster = ImageAdjuster()

    @Published var currentFilter: Int = 0   // フィルタViewでどの効果を選択するかのパラメータ
    @Published var imgFilterNum: Int = 10
    private var filter = ImageFilter()



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
            print("session start")
        }

        // タイトルを見せるためだけの遅延
        // TODO: 将来的に不要になる可能性あり
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {self.canUse = true}

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

        if !self.isCameraBack { // フロントカメラの左右反転を修正
            ciImage = ciImage.transformed(by: CGAffineTransform(scaleX: 1, y: -1))
        }
        // TODO:  何らかの画像処理を行う
        adjuster.size = self.adjusterSize

        ciImage = adjuster.size[1] != 0 ? adjuster.brightness(ciImage) : ciImage
        ciImage = adjuster.size[2] != 0 ? adjuster.contrast(ciImage) : ciImage
        ciImage = adjuster.size[3] != 0 ? adjuster.saturation(ciImage) : ciImage
        ciImage = adjuster.size[4] != 0 ? adjuster.vibrance(ciImage) : ciImage
        ciImage = adjuster.size[5] != 0 ? adjuster.shadow(ciImage) : ciImage
        ciImage = adjuster.size[6] != 0 ? adjuster.highlight(ciImage) : ciImage
        ciImage = adjuster.size[7] != 0 ? adjuster.temperature(ciImage) : ciImage
        ciImage = adjuster.size[8] != 0 ? adjuster.hue(ciImage) : ciImage
        ciImage = adjuster.size[9] != 0 ? adjuster.sharpness(ciImage) : ciImage
        ciImage = adjuster.size[10] != 0 ? adjuster.gaussian(ciImage) : ciImage

        // CGImageに変換(画面の向き情報を保持するため)
        // GPUアクセラレーションを有効
        let context = CIContext(options: [CIContextOption.useSoftwareRenderer: false])
        let cgImage: CGImage? = context.createCGImage(ciImage, from: ciImage.extent)

        // UIImageに変換
        if let img = cgImage {
            self.uiImage = UIImage(cgImage: img, scale: 3, orientation: .right)
        } else { return }
    }

    func setting() {
        //        self.photoSettings.photoQualityPrioritization = .quality
        self.session.sessionPreset = .hd1920x1080
    }

    func takePhoto() {
        print("takePhoto")
        self.canUse = false
        self.session.stopRunning()
        var ciImage: CIImage
        var cgImg: CGImage

        if let img = self.uiImage.cgImage {
            print("CGImgae変換")
            cgImg = img
        } else {
            print("CGImgae変換 / failed")
            return
        }

        ciImage = CIImage(cgImage: cgImg)

        // 画面の向きを考慮した画像の取得
        ciImage = ciImage.transformed(by: CGAffineTransform(rotationAngle: round(-90.0*powl(Double(UIDevice.current.orientation.rawValue)-3.5+1.0/(4.0*Double(UIDevice.current.orientation.rawValue)-14.0), -11))*Double.pi/180.0))
        let context = CIContext()
        let cgImage: CGImage? = context.createCGImage(ciImage, from: ciImage.extent)

        // UIImageに変換
        if let img = cgImage {
            self.uiImage = UIImage(cgImage: img, scale: 3, orientation: .right)
            print("UIImage変換")
        } else {

            print("UIImage変換 / failed")
            return
        }
    }

    // シャッターボタンを押した後に保存するか戻るかを選択する機能
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
}
