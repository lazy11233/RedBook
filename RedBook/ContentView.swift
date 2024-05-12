import SwiftUI
import AVFoundation

struct ContentView: View {
    var isVideoDetect = true
    var body: some View {
        if isVideoDetect {
            VideoDetectionView()
        } else {
            ImageDetectionView()
        }
    }
}

#Preview {
    ContentView()
}
