import SwiftUI
import UIKit

// IMPORTANT: NSCameraUsageDescription muss in den Build-Settings (INFOPLIST_KEY_NSCameraUsageDescription)
// oder Info.plist gesetzt sein, sonst crasht die App beim Kamera-Zugriff.
// Wert: "SpotterDex benötigt die Kamera, um Flugzeuge zu erkennen."

/// UIKit-Bridge für UIImagePickerController (Kamera oder Bibliothek).
struct CameraView: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    let onCapture: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.allowsEditing = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView

        init(_ parent: CameraView) { self.parent = parent }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                parent.onCapture(image)
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
