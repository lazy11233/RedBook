import SwiftUI
import AVFoundation

struct ContentView: View {
    var isVideoDetect = true
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
