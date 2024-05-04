import SwiftUI
import Vision

class DetectionTool: NSObject {
    var diceDetectionRequest: VNCoreMLRequest!
    typealias DetectHandle = ((_ targetArr: [PositionModel]) -> ())

    func detectImage(image: UIImage, _ callback: @escaping DetectHandle) {
        guard let mlModel = try? glue_detection(configuration: .init()).model,
              let detector = try? VNCoreMLModel(for: mlModel) else {
            print("Failed to load detector!")
            return
        }
        let handler = VNImageRequestHandler(cvPixelBuffer: convertImage2CV(from: image)!, options: [:])
        diceDetectionRequest = VNCoreMLRequest(model: detector) { [self] request, error in
            if let error = error {
                print("An error occurred with the vision request: \(error.localizedDescription)")
                return
            }
            self.detectionRequestHandler(
                request: request,
                image: image,
                callback
            )
        }
        diceDetectionRequest.imageCropAndScaleOption = .scaleFill
        
        DispatchQueue.global().async {
            do {
                try handler.perform([self.diceDetectionRequest])
            } catch {
                print("CoreML request failed with error: \(error.localizedDescription)")
            }
        }
    }

    private  func getDeviceOri() -> CGImagePropertyOrientation {
        let orientation = UIDevice.current.orientation
        let imageOrientation: CGImagePropertyOrientation
        switch orientation {
        case .portrait:
            imageOrientation = .right
        case .portraitUpsideDown:
            imageOrientation = .left
        case .landscapeLeft:
            imageOrientation = .up
        case .landscapeRight:
            imageOrientation = .down
        case .unknown:
            print("The device orientation is unknown, the predictions may be affected")
            fallthrough
        default:
            imageOrientation = .up
        }
        return imageOrientation
    }
    
    private func detectionRequestHandler(
        request: VNRequest, image: UIImage, _ callback: DetectHandle
    ) {
        guard let request = request as? VNCoreMLRequest else {
            print("Vision request is not a VNCoreMLRequest")
            return
        }
        guard let observations = request.results as? [VNRecognizedObjectObservation] else {
            print("Request did not return recognized objects: \(request.results?.debugDescription ?? "[No results]")")
            return
        }
        // 1. 获取识别到的VNTextObservation
        var targetRects: [PositionModel] = []
        // 2. 创建rect数组
        for observation in observations {
            guard let topLabel = observation.labels.first?.identifier else {
                print("Object observation has no labels")
                continue
            }
            if observation.confidence > 0.3 {
                let position = self.bounds(for: observation)
                targetRects.append(PositionModel(label: topLabel, position: position, confidence: observation.confidence))
            }
        }
        callback(targetRects)
    }
    
    private func bounds(for observation: VNRecognizedObjectObservation) -> CGRect {

        let boundingBox = observation.boundingBox
        
        // 该Y坐标与UIView的Y坐标是相反的
        let fixedBoundingBox = CGRect(
            x: boundingBox.origin.x,
            y: 1.0 - boundingBox.origin.y - boundingBox.height,
            width: boundingBox.width,
            height: boundingBox.height
        )
        return VNImageRectForNormalizedRect(fixedBoundingBox, Int(kScreenWidth), Int(kScreenHeight))
    }

    /// 将普通UIImage对象转换成CVPixelBuffer
    private func convertImage2CV(from image: UIImage) -> CVPixelBuffer? {
        // Set the dimensions required by the model
        let width = Int(kScreenWidth - 40)  // replace 224 with the width required by the model
        let height = Int(kScreenWidth - 40)  // replace 224 with the height required by the model

        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), true, 2.0)
        image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard status == kCVReturnSuccess else {
            return nil
        }

        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

        context?.translateBy(x: 0, y: CGFloat(height))
        context?.scaleBy(x: 1.0, y: -1.0)

        UIGraphicsPushContext(context!)
        resizedImage.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

        return pixelBuffer
    }
}
