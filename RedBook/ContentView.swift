import SwiftUI
import AVFoundation

struct ContentView: View {
    var isVideoDetect = false
    var body: some View {
        if isVideoDetect {
            HostedViewController()
                .ignoresSafeArea()
        } else {
            ImageDetectionView()
        }
    }
}

#Preview {
    ContentView()
}
