import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var model = FrameHandle()
    var body: some View {
        ZStack {
            Color.pink
                .opacity(0.5)
                .ignoresSafeArea()

            FrameView(image: model.frame)
                .frame(width: 400, height: 400)
        }
    }
}

#Preview {
    ContentView()
}
