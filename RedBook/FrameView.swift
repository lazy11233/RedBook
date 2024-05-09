import SwiftUI

struct FrameView: View {
    var image: CGImage?
    private let label = Text("Frame")
    var body: some View {
        if let image {
            Image(image, scale: 1.0, orientation: .up, label: label)
        } else {
            Color.red
        }
    }
}

#Preview {
    FrameView()
}
