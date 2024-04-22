import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State var image: UIImage?
    var body: some View {
        VStack {
            PhotosPicker("选择一张图片", selection: $selectedItem, matching: .images)
                .onChange(of: selectedItem) { oldValue, newValue in
                    Task {
                        if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                            image = UIImage(data: data)
                        }
                        print("加载图片失败")
                    }
                }
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
        }
    }
}

#Preview {
    ContentView()
}
