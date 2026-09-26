import Foundation
@testable import PixelPeeper
import Testing

/// `.cropToOverlap` compares only the area both images cover, anchored at the
/// top-left, without resampling either one.
@Suite("ImageComparator cropping to the overlap")
struct ImageComparatorCropToOverlapTests {
    private let options = ComparisonOptions(dimensionMismatch: .cropToOverlap)

    @Test("a taller image whose extra rows differ matches over the overlap")
    func extraRowsIgnored() throws {
        let short = PixelImage(width: 2, height: 1, pixels: [
            255, 0, 0, 255, 0, 255, 0, 255,
        ])
        let tall = PixelImage(width: 2, height: 2, pixels: [
            255, 0, 0, 255, 0, 255, 0, 255,
            0, 0, 0, 0, 0, 0, 0, 0,
        ])

        let result = try ImageComparator.compare(short, tall, options: options)

        #expect(result.maeSteps == 0)
        #expect(result.mae == 0)
    }

    @Test("a wider image whose extra columns differ matches over the overlap")
    func extraColumnsIgnored() throws {
        let narrow = PixelImage(width: 1, height: 2, pixels: [
            255, 0, 0, 255,
            0, 255, 0, 255,
        ])
        let wide = PixelImage(width: 2, height: 2, pixels: [
            255, 0, 0, 255, 9, 9, 9, 9,
            0, 255, 0, 255, 9, 9, 9, 9,
        ])

        #expect(try ImageComparator.compare(wide, narrow, options: options).maeSteps == 0)
    }

    @Test("each image is cropped on the axis where it is the larger")
    func crossedSizes() throws {
        // 2×1 against 1×2: the overlap is the single top-left pixel.
        let wide = PixelImage(width: 2, height: 1, pixels: [
            0, 0, 0, 255, 255, 255, 255, 255,
        ])
        let tall = PixelImage(width: 1, height: 2, pixels: [
            0, 0, 0, 251,
            255, 255, 255, 255,
        ])

        #expect(try ImageComparator.compare(wide, tall, options: options).maeSteps == 1)
    }

    @Test("equal sizes compare every pixel, as with the default")
    func equalSizes() throws {
        let a = PixelImage(width: 1, height: 1, pixels: [0, 0, 0, 255])
        let b = PixelImage(width: 1, height: 1, pixels: [0, 0, 4, 255])

        let cropped = try ImageComparator.compare(a, b, options: options)
        let strict = try ImageComparator.compare(a, b)

        #expect(cropped.maeSteps == 1)
        #expect(cropped == strict)
    }

    @Test("round-trips through JSON")
    func optionCodable() throws {
        let data = try JSONEncoder().encode(options)
        let decoded: ComparisonOptions = try JSONDecoder().decode(ComparisonOptions.self, from: data)

        #expect(decoded == options)
    }
}
