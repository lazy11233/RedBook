import SwiftUI
import Vision

class ImageDetectTool: NSObject {
    private var detectorModel: VNCoreMLModel!
    typealias DetectHandler = ([VNRecognizedObjectObservation]) -> Void
    
    override init() {
        guard let mlModel = try? glue_detection(configuration: .init()).model,
              let detecotr = try? VNCoreMLModel(for: mlModel) else {
            print("Failed to load detector!")
            return
        }
        self.detectorModel = detecotr
    }
    
    func detectImage(image: UIImage, _ callback: @escaping DetectHandler) {
        let request = VNCoreMLRequest(model: detectorModel) { request, error in
            if let error = error {
                print("An error occurred with the vision request: \(error.localizedDescription)")
                return
            }
            guard let observations = request.results as? [VNRecognizedObjectObservation] else {
                return
            }
            callback(observations.filter({ $0.confidence > 0.3 }))
        }
        guard let ciImage = CIImage(image: image) else {
            print("The image not found")
            return
        }
        request.imageCropAndScaleOption = .scaleFit
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        DispatchQueue.global().async {
            do {
                try handler.perform([request])
            } catch {
                print("CoreML request failed with error: \(error.localizedDescription)")
            }
        }
        
    }
}
