import SwiftUI
import Vision

struct ImageDetectionView: View {
    @State var isPresenting: Bool = false
    @State var uiImage: UIImage?
    @State var sourceType: UIImagePickerController.SourceType = .camera
    var detectionTool = ImageDetectTool()
    let version = "V0.0.3"
    
    @State private var objectCount: Int = 0
    @State private var detectedRectangles: [TargetPoint] = []
    
    var body: some View {
        VStack{
            if uiImage != nil {
                Image(uiImage: uiImage!)
                    .resizable()
                    .scaledToFit()
                    .overlay (
                        ForEach(detectedRectangles, id: \.self.id) { item in
                            GeometryReader { geometry in
                                HStack {
                                    Rectangle()
                                        .path(in: CGRect(
                                            x: sourceType == .camera ? item.position.minY * geometry.size.width : item.position.minX * geometry.size.width,
                                            y: sourceType == .camera ? item.position.minX * geometry.size.height : item.position.minY * geometry.size.height,
                                            width: sourceType == .camera ? item.position.width * geometry.size.height : item.position.width * geometry.size.width,
                                            height: sourceType == .camera ? item.position.height * geometry.size.width : item.position.height * geometry.size.height
                                        ))
                                        .stroke(.green)
                                        .overlay (
                                            Text("\(item.label):\(String(format: "%.2f", item.confidence))")
                                                .foregroundStyle(.green)
                                                .font(.system(size: 10))
                                                .position(
                                                    x: sourceType == .camera ? item.position.minY * geometry.size.width : item.position.minX * geometry.size.width,
                                                    y: sourceType == .camera ? item.position.minX * geometry.size.height - 5 : item.position.minY * geometry.size.height - 5
                                                )
                                        )
                                }
                            }
                        }
                    )
            }
        }
        .sheet(isPresented: $isPresenting){
            ImagePicker(uiImage: $uiImage, isPresenting: $isPresenting, sourceType: $sourceType)
                .onDisappear {
                    if uiImage != nil {
                        detectionTool.detectImage(image: uiImage!) { observations in
                            self.detectedRectangles = observations.map({ item in
                                return TargetPoint(label: item.labels.first?.identifier ?? "", position: item.boundingBox, confidence: item.confidence)
                            })
                        }
                    }
                }
        }
        .padding()
        Spacer()
        HStack {
            Button {
                isPresenting = true
                sourceType = .photoLibrary
            } label: {
                Image(systemName: "photo")
                    .backgroundStyle(.blue)
            }
             
            Button {
                isPresenting = true
                sourceType = .camera
            } label: {
                Image(systemName: "camera")
            }
        }
        .font(.largeTitle)
        .foregroundColor(.blue)
        Divider()
        Text(" Audio Home iPhone AOI")
                                .font(.caption) // Smaller font size
                                .foregroundStyle(.gray)
                            Text(version.uppercased())
                                .font(.caption) // Smaller font size
    }
}

#Preview {
    ImageDetectionView()
}
