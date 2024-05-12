import SwiftUI
import Vision

struct ImageDetectionView: View {
    @State var isPresenting: Bool = false
    @State var uiImage: UIImage?
    @State var sourceType: UIImagePickerController.SourceType = .camera

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
                    .overlay (
                        ForEach(detectedRectangles, id: \.self.id) { item in
                            GeometryReader { geometry in
                                HStack {
                                    Rectangle()
                                        .path(in: CGRect(
                                            x: item.position.minX * geometry.size.width,
                                            y: item.position.minY * geometry.size.height + 10,
                                            width: item.position.width * geometry.size.width,
                                            height: item.position.height * geometry.size.height)
                                        )
                                        .stroke(.green)
                                        .overlay (
                                            Text("\(item.label):\(String(format: "%.3f", item.confidence))")
                                                .foregroundStyle(.green)
                                                .font(.system(size: 10))
                                                .position(
                                                    x: item.position.minX * geometry.size.width,
                                                    y: item.position.minY * geometry.size.height + 5
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
                            detect(uiImage: uiImage!)
                        }
                    }
            }
            .padding()
    }
    
    func detect(uiImage: UIImage) {
        guard let ciImage = CIImage(image: uiImage) else {
            print("The image not found")
            return
        }
        guard let mlModle = try? glue_detection(configuration: .init()).model else {
            print("Failed to load model.")
            return
        }
        guard let visionModel = try? VNCoreMLModel(for: mlModle) else {
            return
        }
        let request = VNCoreMLRequest(model: visionModel) { request, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            guard let observations = request.results as? [VNRecognizedObjectObservation] else {
                return
            }
            DispatchQueue.main.async {
                detectedRectangles = observations
                    .filter { $0.confidence > 0.3 }
                    .map {
                        TargetPoint(label: $0.labels.first?.identifier ?? "unknown", position: $0.boundingBox, confidence: $0.confidence)
                    }
                objectCount = detectedRectangles.count
            }
        }
        #if targetEnvironment(simulator)
        request.usesCPUOnly = true
        #endif
        let handler = VNImageRequestHandler(ciImage: ciImage)
        do {
            try handler.perform([request])
        } catch {
            print("Error: \(error)")
        }
    }
}

#Preview {
    ImageDetectionView()
}
