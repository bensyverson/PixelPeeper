@preconcurrency import ArgumentParser
import Foundation
import PixelPeeper

/// Generates a visual diff between two images and saves it as a PNG.
struct DiffCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "diff",
        abstract: "Generate a visual diff between two images.",
    )

    /// Path to the first image.
    @Argument(help: "Path to the first image.")
    var image1: String

    /// Path to the second image.
    @Argument(help: "Path to the second image.")
    var image2: String

    /// Intensity multiplier for the difference visualization.
    @Option(name: .long, help: "Intensity multiplier for differences (default: 1.0).")
    var intensity: Double = 1.0

    /// Output file path.
    @Option(name: .long, help: "Output PNG file path.")
    var output: String

    /// Resize the larger image to match the smaller on dimension mismatch.
    @Flag(name: .long, help: "Resize larger image to match smaller on dimension mismatch.")
    var resize: Bool = false

    /// Scale factor for rasterizing vector formats like PDF.
    @Option(name: .long, help: "Scale factor for rasterizing vector formats like PDF (default: 2).")
    var scale: Int = 2

    func validate() throws {
        guard intensity > 0 else {
            throw ValidationError("Intensity must be greater than 0.")
        }
    }

    func run() async throws {
        let url1 = URL(fileURLWithPath: image1)
        let url2 = URL(fileURLWithPath: image2)

        var img1 = try PixelImage.load(from: url1, scale: scale)
        var img2 = try PixelImage.load(from: url2, scale: scale)

        if resize, img1.width != img2.width || img1.height != img2.height {
            let targetWidth = min(img1.width, img2.width)
            let targetHeight = min(img1.height, img2.height)
            if img1.width != targetWidth || img1.height != targetHeight {
                img1 = try img1.resized(toWidth: targetWidth, height: targetHeight)
            }
            if img2.width != targetWidth || img2.height != targetHeight {
                img2 = try img2.resized(toWidth: targetWidth, height: targetHeight)
            }
        }

        let result = try img1.diff(with: img2, intensity: intensity)

        let outputURL = URL(fileURLWithPath: output)
        try result.writePNG(to: outputURL)
    }
}
