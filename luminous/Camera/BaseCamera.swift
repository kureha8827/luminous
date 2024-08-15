import SwiftUI
import AVKit
import AVFoundation


final class BaseCamera: NSObject, @unchecked Sendable, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    let session = AVCaptureSession()
    let output = AVCaptureVideoDataOutput()
    let context = CIContext(    // CIImage->CGImage変換用
        mtlDevice: MTLCreateSystemDefaultDevice()!
    )
    var device: AVCaptureDevice?
    var inputDevice: AVCaptureDeviceInput!
    let deviceTypes: [AVCaptureDevice.DeviceType] = [.builtInTripleCamera, .builtInDualWideCamera, .builtInDualCamera, .builtInWideAngleCamera]

    var isFirstLaunch: Bool = true
    @Published var canUse: Bool = false         // 不具合が起こらないように意図的にカメラの使用を制限する
    @Published var isShowCamera: Bool = true    // falseでカメラ画面にぼかしを入れる
    @Published var isCameraBack: Bool = true
    @Published var uiImage: UIImage = UIImage()
    let camFmt = CameraFormatter()

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
    var time: Float = 0
    var isTimerValid = false

    // ズーム機能
    private var standardZoomFactor: CGFloat = 2.0
    var minFactor: CGFloat = 1.0
    var maxFactor: CGFloat = 10.0
    @Published var linearZoomFactor: Float = 2.0 {
        didSet {
            Task { @MainActor in
                self.zoom(self.linearZoomFactor)
            }
        }
    }


    override init() {
        adjuster = ImageAdjuster()
        adjusterSize = Array(repeating: Float(0), count: ConstStruct.adjusterNum)
        filter = ImageFilter(size: Array(repeating: Float(0), count: ConstStruct.filterNum))
        filterSize = Array(repeating: Float(0), count: ConstStruct.filterNum)
        super.init()
    }


    // PhotoViewが更新されるたびに呼ばれる
    func startSession() async {
        Task.detached(priority: .background) {
            await self.captureSession()
        }
//        try? await Task.sleep(for: .seconds(0.5))
        await self.changeCanUse()
    }


    func captureSession() async {
        // 設定変更を開始
        self.session.beginConfiguration()
        // カメラデバイスのプロパティ設定と、プロパティの条件を満たしたカメラデバイスの取得
        // AVCaptureDeviceInputを生成, デバイス取得時に機種によりエラーが起こる可能性があることを想定する
        self.device = AVCaptureDevice.DiscoverySession(deviceTypes: self.deviceTypes, mediaType: .video, position: .back).devices.first

        // ズームの初期値の選定等
        if let device = self.device {    // シャドーイング
            for (index, actualDevice) in device.constituentDevices.enumerated() {
                if (actualDevice.deviceType != .builtInUltraWideCamera) {
                    if index > 0 && index <= device.virtualDeviceSwitchOverVideoZoomFactors.count {
                        self.standardZoomFactor = CGFloat(truncating: device.virtualDeviceSwitchOverVideoZoomFactors[index - 1])
                    }
                    break
                }
            }
            self.minFactor = device.minAvailableVideoZoomFactor
            self.maxFactor = min(device.maxAvailableVideoZoomFactor, 15.0)
            self.inputDevice = try? AVCaptureDeviceInput(device: device)
        }

        // インプット元をセッションに追加
        if self.session.canAddInput(self.inputDevice) {
            self.session.addInput(self.inputDevice)
        }

        self.session.commitConfiguration()

        // 出力の設定
        self.output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "setSampleBufferDelegate"))
        if self.session.canAddOutput(self.output) {
            self.session.addOutput(self.output)
        }

        // 画質、アス比等の設定
        self.setting()

        Task { @MainActor in
            self.linearZoomFactor = Float(self.standardZoomFactor)
            self.zoom(self.linearZoomFactor)
        }
        
        Task.detached(priority: .background) {
            self.session.startRunning()
        }
    }


    @MainActor
    func changeCanUse() async {
        self.canUse = true
        self.isShowCamera = true
    }


    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if !isShowCamera { return }

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
        filter.output(&ciImage, currentFilter)

        // CGImageに変換
        let cgImage: CGImage? = context.createCGImage(ciImage, from: ciImage.extent)

        // UIImageに変換
        Task { @MainActor in
            if let img = cgImage {
                uiImage = switch optionSelect[1] {
                case 0: UIImage(cgImage: img, scale: 3, orientation: .right)
                case 1: camFmt.cropImageTo3x4(cgImage: img)
                case 2: camFmt.cropImageTo1x1(cgImage: img)
                default: UIImage()
                }
            } else { return }
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
        // カメラの使用を禁止
        self.canUse = false
        self.isShowCamera = false

        // 設定変更を開始
        self.session.beginConfiguration()


        if self.isCameraBack {
            device = AVCaptureDevice.DiscoverySession(deviceTypes: self.deviceTypes, mediaType: .video, position: .back).devices.first
        } else {
            self.optionSelect[2] = 0
            device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        }
        if let device = device {
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

        // すでにセッションにあるインプットを削除
        for input in self.session.inputs {
            self.session.removeInput(input as AVCaptureInput)
        }

        if self.session.canAddInput(self.inputDevice) {
            self.session.addInput(self.inputDevice)
        }

        self.session.commitConfiguration()

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.15))
            self.canUse = true
            try? await Task.sleep(for: .seconds(0.15))
            self.isShowCamera = true
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
}
