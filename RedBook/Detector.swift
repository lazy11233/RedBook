import Vision
import AVFoundation
import UIKit

extension ViewController {
    func setupDetector() {
        guard let mlModel = try? glue_detection(configuration: .init()).model else {
            print("Failed to load detector!")
            return
        }
        do {
            let visionModel = try VNCoreMLModel(for: mlModel)
            let recognitions = VNCoreMLRequest(model: visionModel, completionHandler: detectionDidComplete)
            self.requests = [recognitions]
        } catch let error {
            print(error)
        }
    }
    
    func detectionDidComplete(request: VNRequest, error: Error?) {
        DispatchQueue.main.async(execute: {
            if let results = request.results {
                self.extractDetections(results)
            }
        })
    }
    
    func extractDetections(_ results: [VNObservation]) {
        detectionLyaer.sublayers = nil
                
        for observation in results where observation is VNRecognizedObjectObservation {
            if observation.confidence < 0.3 {
                continue
            }
            guard let objectObservation = observation as? VNRecognizedObjectObservation else { continue }
            
            // Transformations
            let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(screenRect.size.width), Int(screenRect.size.height))
            let transformedBounds = CGRect(x: objectBounds.minX, y: screenRect.size.height - objectBounds.maxY, width: objectBounds.maxX - objectBounds.minX, height: objectBounds.maxY - objectBounds.minY)
            
            let boxLayer = self.drawBoundingBox(transformedBounds)
            
            detectionLyaer.addSublayer(boxLayer)
        }
    }

    func setupLayers() {
        guard let screenRect else {
            print("setupLayers -- View not yet obtained.")
            return
        }
        detectionLyaer = CALayer()
        detectionLyaer.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)
        DispatchQueue.main.async { [weak self] in
            self!.view.layer.addSublayer(self!.detectionLyaer)
        }
    }
        
    func updateLayers() {
        detectionLyaer.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)
    }
    func drawBoundingBox(_ bounds: CGRect) -> CALayer {
        let boxLayer = CALayer()
        boxLayer.frame = bounds
        boxLayer.borderWidth = 1.0
        boxLayer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
        return boxLayer
    }
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
}
