import SwiftUI

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
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
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
