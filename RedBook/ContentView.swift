import SwiftUI
import PhotosUI

func buffer(from image: UIImage) -> CVPixelBuffer? {
  let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
  var pixelBuffer : CVPixelBuffer?
  let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
  guard (status == kCVReturnSuccess) else {
    return nil
  }

  CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
  let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

  let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
  let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

  context?.translateBy(x: 0, y: image.size.height)
  context?.scaleBy(x: 1.0, y: -1.0)

  UIGraphicsPushContext(context!)
  image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
  UIGraphicsPopContext()
  CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

  return pixelBuffer
}

struct ContentView: View {
    @State var showCamera = false
    @State var image: UIImage?
    @State var txt = ""
    @State var probs: Double = 0.0
    let model = Animals10()
    var body: some View {
        VStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                Text("种类：\(txt)")
                Text("概率：\(probs)")
            }
            Button("拍一张") {
                self.showCamera.toggle()
            }
            .fullScreenCover(isPresented: self.$showCamera) {
                ImagePicker(sourceType: .camera) { image in
                    self.image = image
         
                    if let cv = buffer(from: image) {
                        let pResult = try? model.prediction(image: cv)
                        txt = pResult?.classLabel ?? ""
                        probs = pResult?.classLabelProbs[txt] ?? 0
                    }
                }
            }
        }
        .padding()
        
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    let sourceType: UIImagePickerController.SourceType
    let onImagePicked: (UIImage) -> Void

    func makeCoordinator() -> Coordinator {
        return Coordinator(
            presentationMode: presentationMode,
            sourceType: sourceType,
            onImagePicked: onImagePicked
        )
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @Binding private var presentationMode: PresentationMode
    private let sourceType: UIImagePickerController.SourceType
    private let onImagePicked: (UIImage) -> Void

    init(
        presentationMode: Binding<PresentationMode>,
        sourceType: UIImagePickerController.SourceType,
        onImagePicked: @escaping (UIImage) -> Void) {
        _presentationMode = presentationMode
        self.sourceType = sourceType
        self.onImagePicked = onImagePicked
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        onImagePicked(selectedImage)
        presentationMode.dismiss()
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        presentationMode.dismiss()
    }
}


#Preview {
    ContentView()
}
