import SwiftUI
import AVFoundation

//struct CameraView: UIViewRepresentable {
//    @EnvironmentObject var cam: BaseCamView
//
//    // UIViewRepesentableはSwiftUIでUIKitを使うためのプロトコル
//    func makeUIView(context: Context) -> UIView {
//
//        let height = UIScreen.main.bounds.width * 16 / 9
//        let rect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height)
//        let view = UIView(frame: rect)
//
//        cam.camSetting() // 解像度など
//
////       cam.preview = AVCaptureVideoPreviewLayer(session: cam.session) // この処理を複数回実行するとバグる...?
////        cam.preview.frame = view.frame
////        cam.preview.videoGravity = .resizeAspectFill
////        view.layer.addSublayer(cam.preview)
//
//        let afterDir = "file://" + NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/before/"   // あとからafterに変える
//        let path = URL(string: afterDir)!
//        if let image = UIImage(path: path.appendingPathComponent("temp_\(cam.outputFrameCount).png")) {
//            cam.imageView = UIImageView(image: image)
//            view.addSubview(cam.imageView)
//        }
//
//        DispatchQueue.global().async {
//            cam.session.startRunning()
//        }
//        return view
//    }
//    func updateUIView(_ uiView: UIView, context: Context) {
//    }
//}

class BaseCamView: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published var isCameraBack: Bool = true
    @Published var canUse: Bool = false                 // 不具合が起こらないように故意的にカメラの使用を制限する
    @Published var session = AVCaptureSession()
    @Published var output = AVCaptureVideoDataOutput()
//    @Published var preview: AVCaptureVideoPreviewLayer!
    @Published var photoSettings = AVCapturePhotoSettings()
    @Published var outputFrameCount: Int = 1
    @Published var isTaking: Bool = false
    @Published var isSaved: Bool = false
    @AppStorage("last_pic") var picData = Data(count: 0)
    var inputDevice: AVCaptureDeviceInput!

    // lazyを用いると最初に呼び出した時のみ実行される
    // lazyを用いる理由: セットアップの処理が重く、使われるまでは生成したくないため
    func captureSession() {

        // 設定変更を開始
        self.session.beginConfiguration()
        self.session.sessionPreset = .photo   // 解像度の設定

        // カメラデバイスのプロパティ設定と、プロパティの条件を満たしたカメラデバイスの取得
        // AVCaptureDeviceInputを生成, デバイス取得時に機種によりエラーが起こる可能性があることを想定する
        let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        self.inputDevice = try? AVCaptureDeviceInput(device: device!)

        // インプット元をセッションに追加
        if self.session.canAddInput(self.inputDevice) {
            self.session.addInput(self.inputDevice)
        }

        // アウトプット先をセッションに追加

//        previewLayer.frame = photoView.bounds
//        previewLayer.connection?.videoOrientation = .landscapeRight
//        layer.insertSublayer(previewLayer, at: 100)

        self.session.commitConfiguration()

        self.output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer"))

        if self.session.canAddOutput(self.output) {
            self.session.addOutput(self.output)
        }

        DispatchQueue.main.async {
            self.canUse = true
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
        print("photoOutput")
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
        let ciImage = CIImage(cvImageBuffer: imageBuffer)
        let image = UIImage(ciImage: ciImage)
        guard let data = image.jpegData(compressionQuality: 100) else { return }

        // beforeディレクトリへのパスと保存先の指定
        let path = "file://" + NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/before/"
        guard let path = URL(string: path) else { return }
        let tempFileURL = path.appendingPathComponent("temp_\(self.outputFrameCount).jpg")

        //保存
        if self.canUse {
            do {
                try data.write(to: tempFileURL)
                print("SaveToDoc Done!")

                if self.outputFrameCount < 30 { // 1から30までの数字をループ
                    self.outputFrameCount += 1
                    print("1: \(tempFileURL)")
                } else {
                    self.outputFrameCount = 1
                    print("2: \(tempFileURL)")
                }

            } catch {
                print("failed")
                return
            }
        }

        // セーブ完了
//        DispatchQueue.main.async {
//            self.isSaved = true
//        }
    }

    func camSetting() {
//        self.photoSettings.photoQualityPrioritization = .quality
    }


    // afterディレクトリ内の写真データをUIImageへ変換
    @ViewBuilder
    func camFormatter() -> some View {
        Group{}.onAppear() {
            self.canUse = false
        }
        let afterDir = "file://" + NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/before/"   // あとからafterに変える
        let path = URL(string: afterDir)!
        let tempFileURL = path.appendingPathComponent("temp_\(self.outputFrameCount == 30 ? 1 : self.outputFrameCount + 1).jpg")

//        let afterDir = "file://" + NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/before/"   // あとからafterに変える
//        let path = URL(string: afterDir)!
//        let tempFileURL = path.appendingPathComponent("temp_\(self.outputFrameCount).png")

        let _ = print("############### \(tempFileURL)")
        Image(uiImage: UIImage(path: tempFileURL) ?? UIImage())
            .rotationEffect(.degrees(90))
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 16 / 9)
    }
}
