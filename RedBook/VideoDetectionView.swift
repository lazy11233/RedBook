import SwiftUI
import AVFoundation

struct VideoDetectionView: View {
    let captureSession = AVCaptureSession()
    let captureSessionQueue = DispatchQueue(label: "captureSessionQueue")
    @ObservedObject var captrueDelegate = CaptureDelegate()
    var body: some View {
        ZStack {
            VideoPreviewView(session: captureSession)
                .overlay(
                    ForEach(captrueDelegate.detectedRectangles.indices, id: \.self) { index in
                        GeometryReader { geometry in
                            Rectangle()
                                .path(in: CGRect(
                                    x: captrueDelegate.detectedRectangles[index].minY * geometry.size.height,
                                    y: captrueDelegate.detectedRectangles[index].minX * geometry.size.width,
                                    width: captrueDelegate.detectedRectangles[index].height * geometry.size.height,
                                    height: captrueDelegate.detectedRectangles[index].width * geometry.size.width
                                ))
                                .stroke(Color.red, lineWidth: 1)
                        }
                    }
                )
        }
        .aspectRatio(contentMode: .fit)
        Text("Human count: \(captrueDelegate.peopleCount)")
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
        previewLayer.videoGravity = .resizeAspectFill
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
