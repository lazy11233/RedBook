import SwiftUI
import Vision

struct ImageDetectionView: View {
    var image: String = "peoples"
    @State private var peopleCount: Int = 0
    @State private var detectedRectangles: [CGRect] = []
    @State private var detectWholeBody = false

    var body: some View {
        VStack {
            ZStack {
                Image(uiImage: UIImage(named: image)!)
                    .resizable()
                    .scaledToFit()
                    .overlay (
                        ForEach(detectedRectangles.indices, id: \.self) { index in
                            GeometryReader { geometry in
                                Rectangle()
                                    .path(in: CGRect(
                                        x: detectedRectangles[index].minX * geometry.size.width,
                                        y: detectedRectangles[index].minY * geometry.size.height,
                                        width: detectedRectangles[index].width * geometry.size.width,
                                        height: detectedRectangles[index].height * geometry.size.height)
                                    )
                                    .stroke(Color.red, lineWidth: 1)
                            }
                        }
                    )
                VStack {
                    Toggle("Detect Whole Human", isOn: $detectWholeBody)
                        .padding()
                        .onChange(of: detectWholeBody) { _ in
                            countPeople()
                        }
                }
                Text("People count: \(peopleCount)")
                    .font(.title)
                    .padding()
            }
        }.onAppear {
            countPeople()
        }
    }
    
    func countPeople() {
        guard let uiImage = UIImage(named: image), let ciImage = CIImage(image: uiImage) else {
            print("The image not found")
            return
        }
        let request = VNDetectHumanRectanglesRequest { request, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            guard let observations = request.results as? [VNHumanObservation] else {
                return
            }
            DispatchQueue.main.async {
                peopleCount = observations.count
                detectedRectangles = observations.map {
                    $0.boundingBox
                }
            }
        }
        
        #if targetEnvironment(simulator)
        request.usesCPUOnly = true
        #endif
        
        request.upperBodyOnly = detectWholeBody
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
