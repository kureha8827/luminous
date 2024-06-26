import SwiftUI
import AVKit
import AVFoundation

class BaseCamera: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published var isFirst: Bool = true
    @Published var session = AVCaptureSession()
    @Published var output = AVCaptureVideoDataOutput()
    @Published var canUse: Bool = false         // 不具合が起こらないように意図的にカメラの使用を制限する
    @Published var isShowCamera: Bool = true    // falseでカメラ画面にぼかしを入れる
    @Published var isCameraBack: Bool = true
    @Published var uiImage: UIImage = UIImage()
    let context: CIContext                      // CIImage->CGImage変換用
    private var device: AVCaptureDevice?
    var inputDevice: AVCaptureDeviceInput!
    let deviceTypes: [AVCaptureDevice.DeviceType] = [.builtInTripleCamera, .builtInDualWideCamera, .builtInDualCamera, .builtInWideAngleCamera]

    // 調整機能
    @Published var currentAdjuster: Int = 0     // 調整Viewでどの効果を選択するかのパラメータ
    @Published var adjusterSize: [Float]
    private var adjuster: ImageAdjuster

    // フィルタ機能
    @Published var currentFilter: Int = 0       // フィルタViewでどの効果を選択するかのパラメータ
    @Published var filterSize: [Float]
    private var filter: ImageFilter

    @Published var optionSelect: [Int] = Array(repeating: 0, count: ConstStruct.optionNum)  // オプションの設定

    // フラッシュ機能
    @Published var isFlash: Bool = false

    // タイマー機能
    var timer: Timer?
    var time = 0
    @Published var timeDelta = 0

    // ズーム機能
    private var standardZoomFactor: CGFloat = 2.0
    var minFactor: CGFloat = 1.0
    var maxFactor: CGFloat = 10.0
    @Published var linearZoomFactor: Float = 2.0 {
        didSet {
            DispatchQueue.global(qos: .userInteractive).async {
                self.zoom(self.linearZoomFactor)
            }
        }
    }


    override init() {
        context = CIContext(
            mtlDevice: MTLCreateSystemDefaultDevice()!
        )
        adjuster = ImageAdjuster()
        adjusterSize = Array(repeating: Float(0), count: ConstStruct.adjusterNum)
        filter = ImageFilter(size: Array(repeating: Float(0), count: ConstStruct.filterNum))
        filterSize = Array(repeating: Float(0), count: ConstStruct.filterNum)
        super.init()
    }


    // PhotoViewが更新されるたびに呼ばれる
    func captureSession() {
        print("captureSession")

        // 設定変更を開始
        session.beginConfiguration()

        // カメラデバイスのプロパティ設定と、プロパティの条件を満たしたカメラデバイスの取得
        // AVCaptureDeviceInputを生成, デバイス取得時に機種によりエラーが起こる可能性があることを想定する
        device = AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes, mediaType: .video, position: .back).devices.first
        if let device {
            standardZoomFactor = 2
            for (index, actualDevice) in device.constituentDevices.enumerated() {
                if (actualDevice.deviceType != .builtInUltraWideCamera) {
                    if index > 0 && index <= device.virtualDeviceSwitchOverVideoZoomFactors.count {
                        standardZoomFactor = CGFloat(truncating: device.virtualDeviceSwitchOverVideoZoomFactors[index - 1])
                    }
                    break
                }
            }
            minFactor = device.minAvailableVideoZoomFactor
            maxFactor = min(device.maxAvailableVideoZoomFactor, 15.0)

            inputDevice = try? AVCaptureDeviceInput(device: device)
        }

        // インプット元をセッションに追加
        if session.canAddInput(inputDevice) {
            session.addInput(inputDevice)
        }

        session.commitConfiguration()

        // 出力の設定
        output.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        if session.canAddOutput(output) {
            session.addOutput(output)
        }

        linearZoomFactor = Float(standardZoomFactor)

        // 画質、アス比等の設定
        setting()

        DispatchQueue.global().async {
            self.linearZoomFactor = Float(self.standardZoomFactor)
            self.zoom(self.linearZoomFactor)
            self.session.startRunning()
        }
        // タイトルを見せるためだけの遅延
        // TODO: 将来的に不要になる可能性あり
        if isFirst {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.canUse = true
                self.isShowCamera = true
                self.isFirst = false
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.canUse = true
                self.isShowCamera = true
            }
        }
    }


    func zoom(_ linearFactor: Float) {
        guard let device else {
            return
        }
        try? device.lockForConfiguration()
        device.videoZoomFactor = CGFloat(linearFactor)
        device.unlockForConfiguration()
    }


    func changeCam() {
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.2)) {
                self.canUse = false
                self.isShowCamera = false
            }
        }
        DispatchQueue.global(qos: .userInteractive).async {
            // 設定変更を開始
            self.session.beginConfiguration()

            var device: AVCaptureDevice?

            if self.isCameraBack {
                device = AVCaptureDevice.DiscoverySession(deviceTypes: self.deviceTypes, mediaType: .video, position: .back).devices.first
            } else {
                self.optionSelect[2] = 0
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

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.canUse = true
                self.isShowCamera = true
            }
        }
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

        // 撮影データを生成
        // CIImageに変換(使いやすくするため)
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        var ciImage = CIImage(cvImageBuffer: imageBuffer)

        // フロントカメラの左右反転を修正
        if !isCameraBack {
            ciImage = ciImage.transformed(by: CGAffineTransform(scaleX: 1, y: -1))
        }

        adjuster.size = adjusterSize
        filter.size = filterSize

        // 画像調整処理
        adjuster.output(&ciImage)
        // フィルタ処理
        filter.outputPhotoView(&ciImage, currentFilter)

        // CGImageに変換
        let cgImage: CGImage? = context.createCGImage(ciImage, from: ciImage.extent)

        // UIImageに変換
        if let img = cgImage {
            uiImage = switch optionSelect[1] {
            case 0: UIImage(cgImage: img, scale: 3, orientation: .right)
            case 1: cropImageTo3x4(cgImage: img)
            case 2: cropImageTo1x1(cgImage: img)
            default: UIImage()
            }
        } else { return }
    }


    func camTimer() {
        self.time = (self.optionSelect[3] == 1) ? 3 : 10

        // Timer.scheduledTimerのクロージャ内の処理と同じ
        print("self.time: \(self.time)")
        print("self.timeDelta: \(self.time)")
        self.timeDelta = 1

        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in

            if self.time == 0 {
                timer.invalidate()
            }
            self.time -= 1
            self.timeDelta = 1

            print("self.time: \(self.time)")
        }
    }

    func takePhoto() {
        self.canUse = false

        // タイマー管理
        if self.optionSelect[3] != 0 {
            camTimer()
        }

        // FIXME: Swift6が登場したら見直す
        if (self.optionSelect[3] == 0) {
            // フラッシュオフ
            if self.optionSelect[2] == 0 {

                var ciImage: CIImage

                if let img = self.uiImage.cgImage {
                    ciImage = CIImage(cgImage: img)
                } else {
                    return
                }

                // 画面の向きを考慮した画像の取得
                ciImage = ciImage.transformed(by: CGAffineTransform(rotationAngle: round(-90.0*powl(Double(UIDevice.current.orientation.rawValue)-3.5+1.0/(4.0*Double(UIDevice.current.orientation.rawValue)-14.0), -11))*Double.pi/180.0))
                let context = CIContext()
                let cgImage: CGImage? = context.createCGImage(ciImage, from: ciImage.extent)

                // UIImageに変換
                if let img = cgImage {
                    self.uiImage = UIImage(cgImage: img, scale: 3, orientation: .right)
                }

                self.session.stopRunning()
            } else {    // フラッシュオン
                self.isFlash = true
                guard self.device!.hasTorch else { return }
                try? self.device!.lockForConfiguration()
                if (self.device!.torchMode == .off) {
                    try? self.device!.setTorchModeOn(level: 1.0)
                }
                self.device!.unlockForConfiguration()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                    try? self.device!.lockForConfiguration()
                    self.device!.torchMode = .off
                    self.device!.unlockForConfiguration()

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        try? self.device!.lockForConfiguration()
                        try? self.device!.setTorchModeOn(level: 1.0)
                        self.device!.unlockForConfiguration()

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            var ciImage: CIImage

                            if let img = self.uiImage.cgImage {
                                ciImage = CIImage(cgImage: img)
                            } else {
                                return
                            }

                            // 画面の向きを考慮した画像の取得
                            ciImage = ciImage.transformed(by: CGAffineTransform(rotationAngle: round(-90.0*powl(Double(UIDevice.current.orientation.rawValue)-3.5+1.0/(4.0*Double(UIDevice.current.orientation.rawValue)-14.0), -11))*Double.pi/180.0))
                            let context = CIContext()
                            let cgImage: CGImage? = context.createCGImage(ciImage, from: ciImage.extent)

                            // UIImageに変換
                            if let img = cgImage {
                                self.uiImage = UIImage(cgImage: img, scale: 3, orientation: .right)
                            }


                            self.session.stopRunning()

                            try? self.device!.lockForConfiguration()
                            self.device!.torchMode = .off
                            self.device!.unlockForConfiguration()
                            self.isFlash = false
                        }
                    }
                }
            }
        } else if (self.optionSelect[3] == 1) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                // フラッシュオフ
                if self.optionSelect[2] == 0 {

                    var ciImage: CIImage

                    if let img = self.uiImage.cgImage {
                        ciImage = CIImage(cgImage: img)
                    } else {
                        return
                    }

                    // 画面の向きを考慮した画像の取得
                    ciImage = ciImage.transformed(by: CGAffineTransform(rotationAngle: round(-90.0*powl(Double(UIDevice.current.orientation.rawValue)-3.5+1.0/(4.0*Double(UIDevice.current.orientation.rawValue)-14.0), -11))*Double.pi/180.0))
                    let context = CIContext()
                    let cgImage: CGImage? = context.createCGImage(ciImage, from: ciImage.extent)

                    // UIImageに変換
                    if let img = cgImage {
                        self.uiImage = UIImage(cgImage: img, scale: 3, orientation: .right)
                    }

                    self.session.stopRunning()
                } else {    // フラッシュオン
                    self.isFlash = true
                    guard self.device!.hasTorch else { return }
                    try? self.device!.lockForConfiguration()
                    if (self.device!.torchMode == .off) {
                        try? self.device!.setTorchModeOn(level: 1.0)
                    }
                    self.device!.unlockForConfiguration()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                        try? self.device!.lockForConfiguration()
                        self.device!.torchMode = .off
                        self.device!.unlockForConfiguration()

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            try? self.device!.lockForConfiguration()
                            try? self.device!.setTorchModeOn(level: 1.0)
                            self.device!.unlockForConfiguration()

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                var ciImage: CIImage

                                if let img = self.uiImage.cgImage {
                                    ciImage = CIImage(cgImage: img)
                                } else {
                                    return
                                }

                                // 画面の向きを考慮した画像の取得
                                ciImage = ciImage.transformed(by: CGAffineTransform(rotationAngle: round(-90.0*powl(Double(UIDevice.current.orientation.rawValue)-3.5+1.0/(4.0*Double(UIDevice.current.orientation.rawValue)-14.0), -11))*Double.pi/180.0))
                                let context = CIContext()
                                let cgImage: CGImage? = context.createCGImage(ciImage, from: ciImage.extent)

                                // UIImageに変換
                                if let img = cgImage {
                                    self.uiImage = UIImage(cgImage: img, scale: 3, orientation: .right)
                                }


                                self.session.stopRunning()

                                try? self.device!.lockForConfiguration()
                                self.device!.torchMode = .off
                                self.device!.unlockForConfiguration()
                                self.isFlash = false
                            }
                        }
                    }
                }

            }
        } else if (self.optionSelect[3] == 2) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 11) {
                // フラッシュオフ
                if self.optionSelect[2] == 0 {

                    var ciImage: CIImage

                    if let img = self.uiImage.cgImage {
                        ciImage = CIImage(cgImage: img)
                    } else {
                        return
                    }

                    // 画面の向きを考慮した画像の取得
                    ciImage = ciImage.transformed(by: CGAffineTransform(rotationAngle: round(-90.0*powl(Double(UIDevice.current.orientation.rawValue)-3.5+1.0/(4.0*Double(UIDevice.current.orientation.rawValue)-14.0), -11))*Double.pi/180.0))
                    let context = CIContext()
                    let cgImage: CGImage? = context.createCGImage(ciImage, from: ciImage.extent)

                    // UIImageに変換
                    if let img = cgImage {
                        self.uiImage = UIImage(cgImage: img, scale: 3, orientation: .right)
                    }

                    self.session.stopRunning()
                } else {    // フラッシュオン
                    self.isFlash = true
                    guard self.device!.hasTorch else { return }
                    try? self.device!.lockForConfiguration()
                    if (self.device!.torchMode == .off) {
                        try? self.device!.setTorchModeOn(level: 1.0)
                    }
                    self.device!.unlockForConfiguration()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                        try? self.device!.lockForConfiguration()
                        self.device!.torchMode = .off
                        self.device!.unlockForConfiguration()

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            try? self.device!.lockForConfiguration()
                            try? self.device!.setTorchModeOn(level: 1.0)
                            self.device!.unlockForConfiguration()

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                var ciImage: CIImage

                                if let img = self.uiImage.cgImage {
                                    ciImage = CIImage(cgImage: img)
                                } else {
                                    return
                                }

                                // 画面の向きを考慮した画像の取得
                                ciImage = ciImage.transformed(by: CGAffineTransform(rotationAngle: round(-90.0*powl(Double(UIDevice.current.orientation.rawValue)-3.5+1.0/(4.0*Double(UIDevice.current.orientation.rawValue)-14.0), -11))*Double.pi/180.0))
                                let context = CIContext()
                                let cgImage: CGImage? = context.createCGImage(ciImage, from: ciImage.extent)

                                // UIImageに変換
                                if let img = cgImage {
                                    self.uiImage = UIImage(cgImage: img, scale: 3, orientation: .right)
                                }


                                self.session.stopRunning()

                                try? self.device!.lockForConfiguration()
                                self.device!.torchMode = .off
                                self.device!.unlockForConfiguration()
                                self.isFlash = false
                            }
                        }
                    }
                }

            }
        }
    }


    func setting() {
        switch optionSelect[0] {
        case 0: session.sessionPreset = .hd1920x1080
        case 1: session.sessionPreset = .hd4K3840x2160
        case 2: session.sessionPreset = .hd1280x720
        default: return
        }
    }


    func cropImageTo3x4(cgImage: CGImage) -> UIImage {
        // 元の画像のサイズを取得
        let originalWidth = CGFloat(cgImage.width)
        let originalHeight = CGFloat(cgImage.height)

        // 切り抜き後のサイズを計算
        let cropHeight = originalHeight
        let cropWidth = cropHeight * 4.0 / 3.0

        // 切り抜き領域のY座標を計算 (中央から切り抜く場合)
        let cropX = (originalWidth - cropWidth) / 2.0
        let cropRect = CGRect(x: cropX, y: 0, width: cropWidth, height: cropHeight)

        // CGImageを用いて切り抜き
        guard let croppedCGImage = cgImage.cropping(to: cropRect) else {
            return UIImage()
        }

        // 切り抜いたCGImageからUIImageを作成
        let croppedImage = UIImage(cgImage: croppedCGImage, scale: 3, orientation: .right)

        return croppedImage
    }


    func cropImageTo1x1(cgImage: CGImage) -> UIImage {
        // 元の画像のサイズを取得
        let originalWidth = CGFloat(cgImage.width)
        let originalHeight = CGFloat(cgImage.height)

        // 切り抜き後のサイズを計算
        let cropWidth = originalHeight

        // 切り抜き領域のY座標を計算 (中央から切り抜く場合)
        let cropX = (originalWidth - cropWidth) / 2.0
        let cropRect = CGRect(x: cropX, y: 0, width: cropWidth, height: cropWidth)

        // CGImageを用いて切り抜き
        guard let croppedCGImage = cgImage.cropping(to: cropRect) else {
            return UIImage()
        }

        // 切り抜いたCGImageからUIImageを作成
        let croppedImage = UIImage(cgImage: croppedCGImage, scale: 3, orientation: .right)

        return croppedImage
    }


    // シャッターボタンを押した後に保存するか戻るかを選択する機能
    func takePhotoPrevTransition(_ isTaked: Bool) {
        // TODO:  何らかの処理
        
        if isTaked {
            UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)  {
            DispatchQueue.global().async {
                self.session.startRunning()
                self.canUse = true
            }
        }

    }
}
