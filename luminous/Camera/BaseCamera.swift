import SwiftUI
import AVKit
import AVFoundation

class BaseCamera: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate {
    @Published var session = AVCaptureSession()
    @Published var output = AVCaptureVideoDataOutput()
    @Published var flashOutput = AVCapturePhotoOutput() // フラッシュ用
    @Published var canUse: Bool = false         // 不具合が起こらないように意図的にカメラの使用を制限する
    @Published var isCameraBack: Bool = true
    @Published var uiImage: UIImage = UIImage()
    let context: CIContext                      // CIImage->CGImage変換用
    private var device: AVCaptureDevice?
    var inputDevice: AVCaptureDeviceInput!
    let deviceTypes: [AVCaptureDevice.DeviceType] = [.builtInTripleCamera, .builtInDualWideCamera, .builtInDualCamera, .builtInWideAngleCamera]

    @Published var currentAdjuster: Int = 0     // 調整Viewでどの効果を選択するかのパラメータ
    @Published var adjusterSize: [Float]
    private var adjuster: ImageAdjuster

    @Published var currentFilter: Int = 0       // フィルタViewでどの効果を選択するかのパラメータ
    @Published var filterSize: [Float]
    private var filter: ImageFilter

    @Published var optionSelect: [Int] = Array(repeating: 0, count: ConstStruct.optionNum)  // オプションの設定

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

        // 写真撮影のための出力の設定
        if session.canAddOutput(flashOutput) {
            session.addOutput(flashOutput)
        }

        linearZoomFactor = Float(standardZoomFactor)

        // 画質、アス比等の設定
        setting()

        DispatchQueue.global().async {
            self.session.startRunning()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.linearZoomFactor = Float(self.standardZoomFactor)
                self.zoom(self.linearZoomFactor)
            }
        }
        // タイトルを見せるためだけの遅延
        // TODO: 将来的に不要になる可能性あり
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.canUse = true
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


    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        print("1. photoOutput")
        if let error = error {
            print("Error capturing photo: \(error)")
            return
        }

        guard let imageData = photo.fileDataRepresentation() else {
            print("Error getting image data")
            return
        }

        guard let image = UIImage(data: imageData) else {
            print("Error creating UIImage")
            return
        }
        print("2. photoOutput")
        DispatchQueue.main.async {
            self.uiImage = image
            self.canUse = true
        }
    }


    func takePhoto() {
        canUse = false
        let settings = AVCapturePhotoSettings()
        settings.flashMode = optionSelect[2] == 1 ? .on : .off
        if optionSelect[2] == 1 {
            flashOutput.capturePhoto(with: settings, delegate:  self)
        }
        session.stopRunning()
        var ciImage: CIImage

        if let img = uiImage.cgImage {
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
            uiImage = UIImage(cgImage: img, scale: 3, orientation: .right)
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

        DispatchQueue.global().async {
            self.session.startRunning()
        }
        canUse = true
    }
}
