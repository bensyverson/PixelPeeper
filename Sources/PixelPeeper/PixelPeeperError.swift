/// Errors that can occur during image loading and comparison.
public enum PixelPeeperError: Error, CustomStringConvertible, Equatable, Sendable {
    /// The image file was not found at the given path.
    case fileNotFound(path: String)

    /// The image file could not be loaded.
    case imageLoadFailed(path: String, reason: String)

    /// Pixel data could not be extracted from the image.
    case pixelExtractionFailed(path: String)

    /// The two images have different dimensions.
    case dimensionMismatch(width1: Int, height1: Int, width2: Int, height2: Int)

    public var description: String {
        switch self {
        case let .fileNotFound(path):
            "File not found: \(path)"
        case let .imageLoadFailed(path, reason):
            "Failed to load image at \(path): \(reason)"
        case let .pixelExtractionFailed(path):
            "Failed to extract pixel data from image at \(path)"
        case let .dimensionMismatch(width1, height1, width2, height2):
            "Dimension mismatch: first image is \(width1)×\(height1), second image is \(width2)×\(height2)"
        }
    }
}
