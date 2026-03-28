@preconcurrency import ArgumentParser
import Foundation
import PixelPeeper

/// Command-line tool for computing Mean Absolute Error between two images.
@main
struct PeepCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "peep",
        abstract: "Compute Mean Absolute Error (MAE) between two images."
    )

    /// Path to the first image.
    @Argument(help: "Path to the first image.")
    var image1: String

    /// Path to the second image.
    @Argument(help: "Path to the second image.")
    var image2: String

    /// Output results as JSON.
    @Flag(name: .long, help: "Output results as JSON.")
    var json: Bool = false

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

        if json {
            try print(PeepCommand.formatJSON(result))
        } else {
            print(PeepCommand.formatText(result))
        }

        if let threshold, result.mae > threshold {
            throw ExitCode.failure
        }
    }
}
