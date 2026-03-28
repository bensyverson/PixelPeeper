@preconcurrency import ArgumentParser
import Foundation
import PixelPeeper

/// Computes Mean Absolute Error (MAE) between two images.
struct CompareCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "compare",
        abstract: "Compute Mean Absolute Error (MAE) between two images."
    )

    /// Output format for comparison results.
    enum Format: String, ExpressibleByArgument, CaseIterable, Sendable {
        case text
        case json
    }

    /// Path to the first image.
    @Argument(help: "Path to the first image.")
    var image1: String

    /// Path to the second image.
    @Argument(help: "Path to the second image.")
    var image2: String

    /// Output format.
    @Option(name: .long, help: "Output format (text or json).")
    var format: Format = .text

    /// Resize the larger image to match the smaller on dimension mismatch.
    @Flag(name: .long, help: "Resize larger image to match smaller on dimension mismatch.")
    var resize: Bool = false

    /// Scale factor for rasterizing vector formats like PDF.
    @Option(name: .long, help: "Scale factor for rasterizing vector formats like PDF (default: 2).")
    var scale: Int = 2

    /// Exit with non-zero status if MAE exceeds this value.
    @Option(name: .long, help: "Exit with non-zero status if MAE exceeds this value.")
    var threshold: Double?

    func run() async throws {
        let url1 = URL(fileURLWithPath: image1)
        let url2 = URL(fileURLWithPath: image2)

        let img1 = try PixelImage.load(from: url1, scale: scale)
        let img2 = try PixelImage.load(from: url2, scale: scale)

        let options = ComparisonOptions(
            dimensionMismatch: resize ? .resizeToSmallest : .error
        )

        let result = try ImageComparator.compare(img1, img2, options: options)

        switch format {
        case .text:
            print(CompareCommand.formatText(result))
        case .json:
            try print(CompareCommand.formatJSON(result))
        }

        if let threshold, result.mae > threshold {
            throw ExitCode.failure
        }
    }
}
