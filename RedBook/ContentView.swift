import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var model = FrameHandle()
    var body: some View {
        ZStack {
            Color.green.opacity(0.3)
                .ignoresSafeArea()
            HostedViewController()
                .ignoresSafeArea()
        }
    }
}

#Preview {
    ContentView()
}
