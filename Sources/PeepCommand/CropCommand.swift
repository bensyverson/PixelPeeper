@preconcurrency import ArgumentParser
import Foundation
import PixelPeeper

/// Crops a region from an image and saves it as a PNG.
struct CropCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "crop",
        abstract: "Crop a region from an image and save it as a PNG.",
    )

    /// Path to the image.
    @Argument(help: "Path to the image.")
    var image: String

    /// Horizontal origin of the crop region (0-indexed from left).
    @Option(name: .long, help: "Horizontal origin of the crop region.")
    var x: Int

    /// Vertical origin of the crop region (0-indexed from top).
    @Option(name: .long, help: "Vertical origin of the crop region.")
    var y: Int

    /// Width of the crop region.
    @Option(name: .long, help: "Width of the crop region.")
    var width: Int

    /// Height of the crop region.
    @Option(name: .long, help: "Height of the crop region.")
    var height: Int

    /// Inset to apply to the crop region (shrinks all edges).
    @Option(name: .long, help: "Inset to apply to the crop region (default: 0).")
    var inset: Int = 0

    /// Output file path.
    @Option(name: .long, help: "Output PNG file path.")
    var output: String

    /// Scale factor for rasterizing vector formats like PDF.
    @Option(name: .long, help: "Scale factor for rasterizing vector formats like PDF (default: 2).")
    var scale: Int = 2

    func run() async throws {
        let url = URL(fileURLWithPath: image)
        let img = try PixelImage.load(from: url, scale: scale)

        let adjustedX = x + inset
        let adjustedY = y + inset
        let adjustedWidth = width - 2 * inset
        let adjustedHeight = height - 2 * inset

        let cropped = try img.cropped(
            x: adjustedX, y: adjustedY,
            width: adjustedWidth, height: adjustedHeight,
        )

        let outputURL = URL(fileURLWithPath: output)
        try cropped.writePNG(to: outputURL)
    }
}
