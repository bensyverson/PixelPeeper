import CoreGraphics
import Foundation
@testable import PixelPeeper
import Testing

/// Pins the overlay rasterization against committed PNGs.
///
/// Geometry is asserted pixel-exactly elsewhere; what a golden adds is the
/// text, whose rasterization no arithmetic can predict. Regenerate with
/// `UPDATE_GOLDEN=1 swift test --filter "Overlay snapshots"` and read the
/// diff before committing it.
@Suite("Overlay snapshots")
struct OverlaySnapshotTests {
    /// The largest mean absolute error a golden comparison tolerates.
    ///
    /// Deliberately tight. On the ~26,000-pixel grid golden, one wrong digit
    /// is roughly 30 pixels flipped by most of the channel range — about 0.09
    /// on MAE's 0–100 scale. A tolerance of 1.0 would sail past that and pin
    /// nothing; 0.02 catches it while still absorbing a handful of subpixels
    /// drifting when a toolchain changes its hinting. A failure here is a
    /// prompt to look at the PNG, not to raise the number.
    static let tolerance: Double = 0.02

    static let fixtures: URL = .init(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .appendingPathComponent("Fixtures")

    /// A deterministic source: a pale field with two darker blocks.
    static func source() -> PixelImage {
        let width = 160
        let height = 100
        var pixels = [UInt8]()
        pixels.reserveCapacity(width * height * 4)
        for y in 0 ..< height {
            for x in 0 ..< width {
                let inBlock = (x >= 20 && x < 60 && y >= 20 && y < 50)
                    || (x >= 90 && x < 140 && y >= 60 && y < 90)
                let value: UInt8 = inBlock ? 70 : 235
                pixels.append(value)
                pixels.append(value)
                pixels.append(inBlock ? 160 : 240)
                pixels.append(255)
            }
        }
        return PixelImage(width: width, height: height, pixels: pixels)
    }

    static func check(_ image: PixelImage, against name: String) throws {
        let url = Self.fixtures.appendingPathComponent(name)
        if ProcessInfo.processInfo.environment["UPDATE_GOLDEN"] != nil {
            try FileManager.default.createDirectory(at: Self.fixtures, withIntermediateDirectories: true)
            try image.writePNG(to: url)
        }
        let golden = try PixelImage.load(from: url)
        #expect(golden.width == image.width)
        #expect(golden.height == image.height)
        let result = try ImageComparator.compare(golden, image)
        #expect(result.mae <= Self.tolerance)
    }

    @Test
    func `the labelled grid matches its golden`() throws {
        let gridded = try Self.source().withGrid(
            GridOptions(mode: .rulersAndLines, step: 25), pixelsPerPoint: 2,
        )
        try Self.check(gridded, against: "overlay-grid-golden.png")
    }

    @Test
    func `the labelled outlines match their golden`() throws {
        let outlined = try Self.source().withOutlines([
            Outline(rect: CGRect(x: 10, y: 10, width: 20, height: 15), label: "Header"),
            Outline(
                rect: CGRect(x: 45, y: 30, width: 25, height: 15),
                color: PixelColor(red: 220, green: 40, blue: 120, alpha: 255),
                label: "Card",
                width: 3,
            ),
        ], pixelsPerPoint: 2)
        try Self.check(outlined, against: "overlay-outline-golden.png")
    }
}
