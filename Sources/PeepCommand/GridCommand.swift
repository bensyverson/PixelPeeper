@preconcurrency import ArgumentParser
import Foundation
import PixelPeeper

/// Overlays a grid on an image and saves it as a PNG.
struct GridCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "grid",
        abstract: "Overlay a grid on an image and save it as a PNG.",
    )

    /// Path to the image.
    @Argument(help: "Path to the image.")
    var image: String

    /// Spacing between grid lines in pixels.
    @Option(name: .long, help: "Spacing between grid lines in pixels.")
    var spacing: Int

    /// Grid line color as a hex string.
    @Option(name: .long, help: "Grid line color as hex (#RRGGBB or #RRGGBBAA, default: #ff0000).")
    var color: String = "#ff0000"

    /// Output file path.
    @Option(name: .long, help: "Output PNG file path.")
    var output: String

    /// Scale factor for rasterizing vector formats like PDF.
    @Option(name: .long, help: "Scale factor for rasterizing vector formats like PDF (default: 2).")
    var scale: Int = 2

    func run() async throws {
        let url = URL(fileURLWithPath: image)
        let img = try PixelImage.load(from: url, scale: scale)

        let gridColor = try PixelColor(hex: color)
        let result = img.withGridOverlay(spacing: spacing, color: gridColor)

        let outputURL = URL(fileURLWithPath: output)
        try result.writePNG(to: outputURL)
    }
}
