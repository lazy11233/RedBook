import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var model = FrameHandle()
    @State var showState = false
    var body: some View {
        ZStack {
            Color.green.opacity(0.1)
                .ignoresSafeArea()
            HostedViewController()
                .ignoresSafeArea()
        }
    }
}

#Preview {
    ContentView()
}
