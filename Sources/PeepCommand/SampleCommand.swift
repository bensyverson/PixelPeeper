@preconcurrency import ArgumentParser
import Foundation
import PixelPeeper

/// Samples the color of a pixel at given coordinates in an image.
struct SampleCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "sample",
        abstract: "Sample the color of a pixel at given coordinates."
    )

    /// Output format for the sampled color.
    enum Format: String, ExpressibleByArgument, CaseIterable, Sendable {
        case hex
        case text
        case json
    }

    /// Path to the image.
    @Argument(help: "Path to the image.")
    var image: String

    /// Horizontal coordinate (0-indexed from left).
    @Argument(help: "Horizontal coordinate (0-indexed from left).")
    var x: Int

    /// Vertical coordinate (0-indexed from top).
    @Argument(help: "Vertical coordinate (0-indexed from top).")
    var y: Int

    /// Output format.
    @Option(name: .long, help: "Output format (hex, text, or json).")
    var format: Format = .hex

    /// Scale factor for rasterizing vector formats like PDF.
    @Option(name: .long, help: "Scale factor for rasterizing vector formats like PDF (default: 2).")
    var scale: Int = 2

    func run() async throws {
        let url = URL(fileURLWithPath: image)
        let img = try PixelImage.load(from: url, scale: scale)
        let color = try img.color(atX: x, y: y)

        switch format {
        case .hex:
            print(SampleCommand.formatHex(color))
        case .text:
            print(SampleCommand.formatText(color))
        case .json:
            try print(SampleCommand.formatJSON(color))
        }
    }
}
