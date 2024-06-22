import SwiftUI
import AVKit
import AVFoundation

class BaseCamera: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @AppStorage("last_pic") var picData = Data(count: 0)
    @Published var isCameraBack: Bool = true
    @Published var canUse: Bool = false                 // 不具合が起こらないように意図的にカメラの使用を制限する
    @Published var session = AVCaptureSession()
    @Published var output = AVCaptureVideoDataOutput()
    @Published var photoSettings = AVCapturePhotoSettings()
    @Published var outputFrameCount: Int = 1
    @Published var uiImage: UIImage = UIImage()

    @Published var currentAdjuster: Int = 0 // 調整Viewでどの効果を選択するかのパラメータ
    @Published var adjusterSize: [Float]
    private var adjuster: ImageAdjuster

    @Published var currentFilter: Int = 0   // フィルタViewでどの効果を選択するかのパラメータ
    @Published var filterSize: [Float]
    private var filter: ImageFilter

    let context: CIContext

    private var device: AVCaptureDevice?
    var inputDevice: AVCaptureDeviceInput!
    let deviceTypes: [AVCaptureDevice.DeviceType] = [.builtInTripleCamera, .builtInDualWideCamera, .builtInDualCamera, .builtInWideAngleCamera]
    var standardZoomFactor: CGFloat = 1.0
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
        self.adjuster = ImageAdjuster()
        self.adjusterSize = Array(repeating: Float(0), count: ConstStruct.adjusterNum)
        self.filter = ImageFilter(size: Array(repeating: Float(0), count: ConstStruct.filterNum))
        self.filterSize = Array(repeating: Float(0), count: ConstStruct.filterNum)
        super.init()
    }


    func captureSession() {

        // 設定変更を開始
        self.session.beginConfiguration()
        self.session.sessionPreset = .photo   // 解像度の設定

        // カメラデバイスのプロパティ設定と、プロパティの条件を満たしたカメラデバイスの取得
        // AVCaptureDeviceInputを生成, デバイス取得時に機種によりエラーが起こる可能性があることを想定する
        device = AVCaptureDevice.DiscoverySession(deviceTypes: self.deviceTypes, mediaType: .video, position: .back).devices.first
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

        self.linearZoomFactor = Float(self.standardZoomFactor)

        // 画質、アス比等の設定
        setting()

        DispatchQueue.global().async {
            self.session.startRunning()
            print("session start")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.linearZoomFactor = Float(self.standardZoomFactor)
                print("Initial Zoom Factor: \(self.linearZoomFactor)")
                self.zoom(self.linearZoomFactor)
            }
        }
        // タイトルを見せるためだけの遅延
        // TODO: 将来的に不要になる可能性あり
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {self.canUse = true}

    }

    func zoom(_ linearFactor: Float) {
        guard let device else {
            return
        }
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = CGFloat(linearFactor)
            device.unlockForConfiguration()
        } catch {
        }
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
                device = AVCaptureDevice.DiscoverySession(deviceTypes: self.deviceTypes, mediaType: .video, position: .back).devices.first
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

        // フロントカメラの左右反転を修正
        if !self.isCameraBack {
            ciImage = ciImage.transformed(by: CGAffineTransform(scaleX: 1, y: -1))
        }

        adjuster.size = self.adjusterSize
        filter.size = self.filterSize

        // 画像調整処理
        adjuster.output(&ciImage)
        // フィルタ処理
        filter.outputPhotoView(&ciImage, self.currentFilter)

        // CGImageに変換
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
        self.canUse = false
        self.session.stopRunning()
        var ciImage: CIImage
        var cgImg: CGImage

        if let img = self.uiImage.cgImage {
            cgImg = img
        } else {
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
