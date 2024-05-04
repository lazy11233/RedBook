import SwiftUI
import PhotosUI
import CoreML
import Vision
import UIKit

/// 屏幕的宽
let kScreenWidth = UIScreen.main.bounds.size.width
/// 屏幕的高
let kScreenHeight = UIScreen.main.bounds.size.height

struct ContentView: View {
    @State var showCamera = false
    @State var image: UIImage?
    @State var shapesRects: [PositionModel] = []
    var detectionTool: DetectionTool!
    let version = "V0.0.2"

    init() {
        detectionTool = DetectionTool()
    }
    var body: some View {
        ZStack {
            if image != nil {
                detectImage
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 200)
                    .foregroundColor(.blue)
                    .opacity(0.6)
                    .padding()
            }
            VStack {
                Spacer()
                VStack {
                    bottomArea
                    Divider() // Adds a horizontal line below the text
                    Text(" Audio Home iPhone AOI")
                        .font(.caption) // Smaller font size
                        .foregroundStyle(.gray)
                    Text(version.uppercased())
                        .font(.caption) // Smaller font size
                }
                .padding(.top, 10)
                .background(.ultraThinMaterial)
            }

        }
    }
}
// MARK: SUBVIEWS
extension ContentView {
    var detectImage: some View {
        Image(uiImage: image!)
            .resizable()
            .frame(width: kScreenWidth, height: kScreenHeight)
            .overlay {
                ForEach(shapesRects, id: \.self.id) { item in
                    HStack {
                        Path(item.position)
                            .stroke(.green)
                            .overlay {
                                Text("\(item.label):\(String(format: "%.3f", item.confidence))")
                                    .foregroundStyle(.green)
                                    .font(.system(size: 10))
                                    .position(x: item.position.minX + 10, y: item.position.minY - 8)
                            }
                    }
                }
            }
    }
    var bottomArea: some View {
        HStack(spacing: 20) {
            Button(action: {
                showCamera.toggle()
            }, label: {
                HStack {
                    Image(systemName: "camera")
                    Text("Camera")
                }
                .padding()
                .foregroundStyle(.white)
                .background(.blue)
                .cornerRadius(30)
            })
            .fullScreenCover(isPresented: $showCamera) {
                ImagePicker(sourceType: .camera, onImagePicked: dealWithImage)
            }
            Button(action: {
                showCamera.toggle()
            }, label: {
                HStack {
                    Image(systemName: "photo.stack")
                    Text("Library")
                }
                .padding()
                .foregroundStyle(.white)
                .background(.blue)
                .cornerRadius(30)
            })
            .fullScreenCover(isPresented: $showCamera) {
                ImagePicker(sourceType: .photoLibrary, onImagePicked: dealWithImage)
            }
            
        }
    }
}

// MARK: FUNCTIONS
extension ContentView {
    func dealWithImage(image: UIImage) {
        self.image = image
        detectionTool.detectImage(image: image) { targetArr in
            self.shapesRects = targetArr
        }
    }
}

#Preview {
    ContentView()
}
