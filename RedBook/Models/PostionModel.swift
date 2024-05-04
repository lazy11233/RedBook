import Foundation

class PositionModel: NSObject {
    let id: String = UUID().uuidString
    let label: String
    let position: CGRect
    let confidence: Float
    
    init(label: String, position: CGRect, confidence: Float) {
        self.label = label
        self.position = position
        self.confidence = confidence
    }
}

