@preconcurrency import ArgumentParser
import Foundation
import PixelPeeper

/// Samples pixel colors along a line between two points.
struct LineSampleCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "linesample",
        abstract: "Sample pixel colors along a line between two points.",
    )

    /// Output format for the line sample results.
    enum Format: String, ExpressibleByArgument, CaseIterable, Sendable {
        case text
        case json
    }

    /// Path to the image.
    @Argument(help: "Path to the image.")
    var image: String

    /// Horizontal coordinate of the start point.
    @Option(name: .long, help: "Horizontal coordinate of the start point.")
    var x1: Int

    /// Vertical coordinate of the start point.
    @Option(name: .long, help: "Vertical coordinate of the start point.")
    var y1: Int

    /// Horizontal coordinate of the end point.
    @Option(name: .long, help: "Horizontal coordinate of the end point.")
    var x2: Int

    /// Vertical coordinate of the end point.
    @Option(name: .long, help: "Vertical coordinate of the end point.")
    var y2: Int

    /// Number of sample points along the line.
    @Option(name: .long, help: "Number of sample points along the line (minimum 2).")
    var steps: Int

    /// Output format.
    @Option(name: .long, help: "Output format (text or json).")
    var format: Format = .text

    /// Scale factor for rasterizing vector formats like PDF.
    @Option(name: .long, help: "Scale factor for rasterizing vector formats like PDF (default: 2).")
    var scale: Int = 2

    func run() async throws {
        let url = URL(fileURLWithPath: image)
        let img = try PixelImage.load(from: url, scale: scale)

        let samples = try img.linearSample(
            from: (x: x1, y: y1),
            to: (x: x2, y: y2),
            steps: steps,
        )

        switch format {
        case .text:
            print(LineSampleCommand.formatText(samples))
        case .json:
            try print(LineSampleCommand.formatJSON(samples))
        }
    }
}
