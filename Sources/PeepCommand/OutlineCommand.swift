@preconcurrency import ArgumentParser
import CoreGraphics
import Foundation
import PixelPeeper

/// Draws labelled boxes around regions of an image and saves it as a PNG.
///
/// A thin adapter over ``PixelImage/withOutlines(_:pixelsPerPoint:origin:)``:
/// it parses rects, builds ``Outline`` values, and writes the result.
struct OutlineCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "outline",
        abstract: "Draw a box around one or more regions of an image and save it as a PNG.",
        discussion: """
        Rects are given in source units — layout points, CSS px, whatever \
        coordinates produced the image — and --scale says how many image \
        pixels one of those units is. At --scale 2, --rect 10,20,100,50 boxes \
        the pixels from (20,40) to (220,140).

        The box is drawn outside the rect, so it never covers the edge pixels \
        of what it points at. With no --color it is drawn two-tone, readable \
        on a light background and a dark one alike.
        """,
    )

    /// Path to the image.
    @Argument(help: "Path to the image.")
    var image: String

    /// A region to box, as `x,y,width,height` in source units. Repeatable.
    @Option(name: .long, help: "Region to box, as x,y,width,height in source units. Repeatable.")
    var rect: [String] = []

    /// Image pixels per source unit.
    @Option(name: .long, help: "Image pixels per source unit (default: 1).")
    var scale: Double = 1

    /// The box colour as a hex string, or the default two-tone ring.
    @Option(name: .long, help: "Box colour as hex (#RRGGBB or #RRGGBBAA). Omit for a two-tone ring.")
    var color: String?

    /// A name for each rect, in the same order. Repeatable.
    @Option(name: .long, help: "Name for a rect, matched in order. Repeatable.")
    var label: [String] = []

    /// The ring's thickness in image pixels.
    @Option(name: .long, help: "Ring thickness in image pixels (default: 2).")
    var width: Double = 2

    /// The source coordinate of the image's top-left pixel.
    @Option(name: .long, help: "Source coordinate of the image's top-left pixel, as x,y (default: 0,0).")
    var origin: String = "0,0"

    /// Output file path.
    @Option(name: [.customLong("out"), .customLong("output")], help: "Output PNG file path.")
    var output: String

    /// Scale factor for rasterizing vector formats like PDF.
    @Option(name: .long, help: "Scale factor for rasterizing vector inputs like PDF (default: 2).")
    var rasterScale: Int = 2

    /// Rejects a malformed rect, origin or colour before any file is opened,
    /// so the complaint arrives with this subcommand's usage rather than the
    /// root command's.
    func validate() throws {
        _ = try outlines()
        _ = try OutlineCommand.parsePoint(origin)
    }

    func run() async throws {
        let source = try PixelImage.load(from: URL(fileURLWithPath: image), scale: rasterScale)
        let result = try source.withOutlines(
            outlines(),
            pixelsPerPoint: scale,
            origin: OutlineCommand.parsePoint(origin),
        )
        try result.writePNG(to: URL(fileURLWithPath: output))
    }

    /// The outlines the flags describe, labels matched to rects in order.
    ///
    /// - Returns: one ``Outline`` per `--rect`.
    /// - Throws: `ValidationError` if a rect or the colour is malformed.
    func outlines() throws -> [Outline] {
        let paint: PixelColor? = try color.map { try PixelColor(hex: $0) }
        return try rect.enumerated().map { index, value in
            try Outline(
                rect: OutlineCommand.parseRect(value),
                color: paint,
                label: index < label.count ? label[index] : nil,
                width: width,
            )
        }
    }

    /// Parses `x,y,width,height`.
    ///
    /// - Parameter value: four comma-separated numbers; spaces are ignored.
    /// - Returns: the rectangle in source units.
    /// - Throws: `ValidationError` naming the expected shape.
    static func parseRect(_ value: String) throws -> CGRect {
        let numbers = try parseNumbers(value, count: 4, shape: "x,y,width,height")
        return CGRect(x: numbers[0], y: numbers[1], width: numbers[2], height: numbers[3])
    }

    /// Parses `x,y`.
    ///
    /// - Parameter value: two comma-separated numbers; spaces are ignored.
    /// - Returns: the point in source units.
    /// - Throws: `ValidationError` naming the expected shape.
    static func parsePoint(_ value: String) throws -> CGPoint {
        let numbers = try parseNumbers(value, count: 2, shape: "x,y")
        return CGPoint(x: numbers[0], y: numbers[1])
    }

    /// Splits a comma-separated list of numbers, insisting on an exact count.
    private static func parseNumbers(_ value: String, count: Int, shape: String) throws -> [Double] {
        let parts = value.split(separator: ",", omittingEmptySubsequences: false)
            .map { $0.trimmingCharacters(in: .whitespaces) }
        guard parts.count == count else {
            throw ValidationError(
                "Expected \(count) comma-separated numbers as '\(shape)'; got '\(value)'.",
            )
        }
        return try parts.map { part in
            guard let number = Double(part) else {
                throw ValidationError(
                    "'\(part)' is not a number; expected '\(shape)', for example '10,20,100,50'.",
                )
            }
            return number
        }
    }
}
