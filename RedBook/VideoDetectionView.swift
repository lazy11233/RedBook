import SwiftUI
import AVFoundation

struct VideoDetectionView: View {
    let captureSession = AVCaptureSession()
    let captureSessionQueue = DispatchQueue(label: "captureSessionQueue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    @ObservedObject var captrueDelegate = CaptureDelegate()
    var body: some View {
        ZStack {
            VideoPreviewView(session: captureSession)
                .overlay(
                    ForEach(captrueDelegate.detectedPoints, id: \.self.id) { item in
                        GeometryReader { geometry in
                            Rectangle()
                                .path(in: CGRect(
                                    x: item.position.minX * geometry.size.width,
                                    y: item.position.minY * geometry.size.height + 10,
                                    width: item.position.width * geometry.size.width,
                                    height: item.position.height * geometry.size.height)
                                )
                                .stroke(.green)
                                .overlay (
                                    Text("\(item.label):\(String(format: "%.3f", item.confidence))")
                                        .foregroundStyle(.green)
                                        .font(.system(size: 10))
                                        .position(
                                            x: item.position.minX * geometry.size.width,
                                            y: item.position.minY * geometry.size.height + 5
                                        )
                                )
                        }
                    }
                )
        }
        .aspectRatio(contentMode: .fit)
        Text("Detect count: \(captrueDelegate.peopleCount)")
            .font(.title)
            .padding()
            .onAppear {
                setupCaptureSession()
            }
            .onDisappear {
                captureSession.stopRunning()
            }
    }
    
    func setupCaptureSession() {
        guard let videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first else {
            print("Failed to create AVCaptureDevice.")
            return
        }
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            print("Faile to create AVCaptureDeviceInput")
            return
        }
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(captrueDelegate, queue: captureSessionQueue)
        
        captureSession.beginConfiguration()
        if captureSession.canAddInput(videoDeviceInput) {
            captureSession.addInput(videoDeviceInput)
        }
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
            videoOutput.alwaysDiscardsLateVideoFrames = true
            videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
        }
        captureSession.commitConfiguration()
        DispatchQueue.global().async {
            captureSession.startRunning()
        }
    }
}

struct VideoPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: .zero)
        // 相机捕获内容的预览层
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.addSublayer(previewLayer)
        return view
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {
        DispatchQueue.main.async {
            if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
                previewLayer.frame = uiView.bounds
            }
        }
    }
}

#Preview {
    VideoDetectionView()
}
