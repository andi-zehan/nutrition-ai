import PhotosUI
import SwiftUI

struct PhotoLibraryPicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var onImagePicked: (UIImage) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 1
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoLibraryPicker
        init(_ parent: PhotoLibraryPicker) { self.parent = parent }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard let provider = results.first?.itemProvider,
                  provider.canLoadObject(ofClass: UIImage.self) else {
                DispatchQueue.main.async { self.parent.isPresented = false }
                return
            }
            provider.loadObject(ofClass: UIImage.self) { [parent] object, _ in
                let image = object as? UIImage
                DispatchQueue.main.async {
                    if let image {
                        let scaled = ImageResizer.resize(image: image, longest: 1600)
                        parent.onImagePicked(scaled)
                    }
                    parent.isPresented = false
                }
            }
        }
    }
}
