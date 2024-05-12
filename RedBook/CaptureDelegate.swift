import AVFoundation
import Vision

class CaptureDelegate: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, ObservableObject {
    @Published var peopleCount: Int = 0
    @Published var detectedPoints: [TargetPoint] = []
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("Could not get image buffer.")
            return
        }
        guard let mlModle = try? glue_detection(configuration: .init()).model else {
            print("Failed to load model.")
            return
        }
        guard let visionModel = try? VNCoreMLModel(for: mlModle) else {
            return
        }
        let request = VNCoreMLRequest(model: visionModel) { request, error in
            if error != nil {
                print("Could not get request from the image.")
                return
            }
            guard let observations = request.results as? [VNRecognizedObjectObservation] else {
                return
            }
            DispatchQueue.main.async { [self] in
                self.detectedPoints = observations
                    .filter { $0.confidence > 0.3 }
                    .map {
                        TargetPoint(label: $0.labels.first?.identifier ?? "unknown", position: $0.boundingBox, confidence: $0.confidence)
                    }
            }
        }

        do {
            try VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
}
