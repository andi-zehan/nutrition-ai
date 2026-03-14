import UIKit

enum ImageResizer {
    /// Resize an image so that its longest side is at most `longest` pixels.
    static func resize(image: UIImage, longest: CGFloat = 1024) -> UIImage {
        guard longest > 0 else { return image }
        let size = image.size
        guard size.width > 0, size.height > 0 else { return image }
        let currentLongest = max(size.width, size.height)
        guard currentLongest > longest else { return image }

        let scaleFactor = longest / currentLongest
        let targetSize = CGSize(
            width: floor(size.width * scaleFactor),
            height: floor(size.height * scaleFactor)
        )

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = image.scale
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }

    /// JPEG data with configurable quality.
    static func jpegData(of image: UIImage, quality: CGFloat = 0.85) -> Data? {
        image.jpegData(compressionQuality: max(0, min(1, quality)))
    }
}
