import Foundation
@testable import PixelPeeper
import Testing

/// The overall MAE in 8-bit channel steps: the mean of every channel's absolute
/// difference, alpha included, on the 0–255 scale the bytes themselves use.
@Suite("ImageComparator in 8-bit steps")
struct ImageComparatorEightBitTests {
    @Test("red against blue is 127.5 steps: two of four channels differ by 255")
    func redVsBlue() throws {
        let red = solid(255, 0, 0, 255, width: 2, height: 2)
        let blue = solid(0, 0, 255, 255, width: 2, height: 2)

        #expect(try ImageComparator.compare(red, blue).maeSteps == 127.5)
    }

    @Test("black against white is 191.25 steps: three of four channels differ by 255")
    func blackVsWhite() throws {
        let black = solid(0, 0, 0, 255, width: 2, height: 2)
        let white = solid(255, 255, 255, 255, width: 2, height: 2)

        #expect(try ImageComparator.compare(black, white).maeSteps == 191.25)
    }

    @Test("alpha counts as a channel")
    func alphaCounts() throws {
        let opaque = solid(0, 0, 0, 255, width: 1, height: 1)
        let clear = solid(0, 0, 0, 0, width: 1, height: 1)

        #expect(try ImageComparator.compare(opaque, clear).maeSteps == 63.75)
    }

    /// The figure is the summed byte difference over the channel count, done once in
    /// `Double`. Callers pin thresholds to the last digit, so it must be bit-identical
    /// to that quotient, not merely close — and the 0–100 figure times 2.55 is not.
    @Test("is exactly the summed difference over the channel count")
    func exactQuotient() throws {
        let base = PixelImage(width: 3, height: 1, pixels: [
            10, 20, 30, 255,
            40, 50, 60, 255,
            70, 80, 90, 255,
        ])
        let other = PixelImage(width: 3, height: 1, pixels: [
            11, 20, 30, 255,
            40, 50, 60, 255,
            70, 80, 90, 254,
        ])

        let result = try ImageComparator.compare(base, other)

        #expect(result.maeSteps.value == Double(2) / Double(12))
    }

    private func solid(
        _ red: UInt8, _ green: UInt8, _ blue: UInt8, _ alpha: UInt8,
        width: Int, height: Int,
    ) -> PixelImage {
        PixelImage(
            width: width, height: height,
            pixels: Array([[UInt8]](repeating: [red, green, blue, alpha], count: width * height).joined()),
        )
    }
}
