import SwiftUI
import Vision

struct ImageDetectionView: View {
    @State var isPresenting: Bool = false
    @State var uiImage: UIImage?
    @State var sourceType: UIImagePickerController.SourceType = .camera
    var detectionTool = ImageDetectTool()

    @State private var objectCount: Int = 0
    @State private var detectedRectangles: [TargetPoint] = []

    var body: some View {
        VStack{
            HStack {
                Image(systemName: "photo")
                    .onTapGesture {
                        isPresenting = true
                        sourceType = .photoLibrary
                    }
                Image(systemName: "camera")
                    .onTapGesture {
                        isPresenting = true
                        sourceType = .camera
                    }
            }
            .font(.largeTitle)
            .foregroundColor(.blue)
            
            if uiImage != nil {
                Image(uiImage: uiImage!)
                    .resizable()
                    .scaledToFit()
                    .border(Color.red)
                    .overlay (
                        ForEach(detectedRectangles, id: \.self.id) { item in
                            GeometryReader { geometry in
                                HStack {
                                    Rectangle()
                                        .path(in: CGRect(
                                            x: item.position.minY * geometry.size.width,
                                            y: item.position.minX * geometry.size.height,
                                            width: item.position.width * geometry.size.height,
                                            height: item.position.height * geometry.size.width)
                                        )
                                        .stroke(.green)
                                        .overlay (
                                            Text("\(item.label):\(String(format: "%.2f", item.confidence))")
                                                .foregroundStyle(.green)
                                                .font(.system(size: 10))
                                                .position(
                                                    x: item.position.minY * geometry.size.width,
                                                    y: item.position.minX * geometry.size.height - 5
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
    }
    func callback(observations: [VNRecognizedObjectObservation]) -> Void {
        
    }
}

#Preview {
    ImageDetectionView()
}
