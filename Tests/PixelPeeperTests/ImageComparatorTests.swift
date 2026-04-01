import Foundation
@testable import PixelPeeper
import Testing

@Suite("ImageComparator")
struct ImageComparatorTests {
    // MARK: - Identity

    @Test("comparing an image to itself yields MAE of 0 for all channels")
    func identityComparison() throws {
        let image = solidImage(red: 128, green: 64, blue: 32, alpha: 255, width: 2, height: 2)
        let result = try ImageComparator.compare(image, image)

        #expect(result.mae == 0.0)
        #expect(result.red == 0.0)
        #expect(result.green == 0.0)
        #expect(result.blue == 0.0)
        #expect(result.alpha == 0.0)
    }

    // MARK: - Known differences

    @Test("red vs blue: R=100, G=0, B=100, A=0, overall=50")
    func redVsBlue() throws {
        let red = solidImage(red: 255, green: 0, blue: 0, alpha: 255, width: 2, height: 2)
        let blue = solidImage(red: 0, green: 0, blue: 255, alpha: 255, width: 2, height: 2)
        let result = try ImageComparator.compare(red, blue)

        #expect(result.red == 100.0)
        #expect(result.green == 0.0)
        #expect(result.blue == 100.0)
        #expect(result.alpha == 0.0)
        #expect(result.mae == 50.0)
    }

    @Test("black vs white: R=100, G=100, B=100, A=0, overall=75")
    func blackVsWhite() throws {
        let black = solidImage(red: 0, green: 0, blue: 0, alpha: 255, width: 2, height: 2)
        let white = solidImage(red: 255, green: 255, blue: 255, alpha: 255, width: 2, height: 2)
        let result = try ImageComparator.compare(black, white)

        #expect(result.red == 100.0)
        #expect(result.green == 100.0)
        #expect(result.blue == 100.0)
        #expect(result.alpha == 0.0)
        #expect(result.mae == 75.0)
    }

    @Test("partially different pixels produce correct averaged MAE")
    func partialDifference() throws {
        // 2×1 image: first pixel red, second pixel red
        let allRed = PixelImage(width: 2, height: 1, pixels: [
            255, 0, 0, 255, // pixel 0: red
            255, 0, 0, 255, // pixel 1: red
        ])
        // 2×1 image: first pixel blue, second pixel red
        let halfBlue = PixelImage(width: 2, height: 1, pixels: [
            0, 0, 255, 255, // pixel 0: blue
            255, 0, 0, 255, // pixel 1: red
        ])
        let result = try ImageComparator.compare(allRed, halfBlue)

        // Only pixel 0 differs: R diff=255, B diff=255, rest 0
        // Per-channel average: R = 255/2 = 127.5 raw → 127.5/2.55 = 50.0
        // B = same as R = 50.0, G = 0, A = 0
        // Overall = (50 + 0 + 50 + 0) / 4 = 25.0
        #expect(result.red == 50.0)
        #expect(result.green == 0.0)
        #expect(result.blue == 50.0)
        #expect(result.alpha == 0.0)
        #expect(result.mae == 25.0)
    }

    // MARK: - Dimension mismatch

    @Test("throws dimensionMismatch when images have different sizes with default options")
    func dimensionMismatchThrows() {
        let small = solidImage(red: 255, green: 0, blue: 0, alpha: 255, width: 2, height: 2)
        let large = solidImage(red: 255, green: 0, blue: 0, alpha: 255, width: 3, height: 3)

        #expect(throws: PixelPeeperError.dimensionMismatch(
            width1: 2, height1: 2,
            width2: 3, height2: 3,
        )) {
            try ImageComparator.compare(small, large)
        }
    }

    // MARK: - Resize to smallest

    @Test("resizeToSmallest succeeds when dimensions differ")
    func resizeToSmallestSucceeds() throws {
        let small = solidImage(red: 255, green: 0, blue: 0, alpha: 255, width: 2, height: 2)
        let large = solidImage(red: 255, green: 0, blue: 0, alpha: 255, width: 4, height: 4)
        let options = ComparisonOptions(dimensionMismatch: .resizeToSmallest)

        let result = try ImageComparator.compare(small, large, options: options)

        // Both solid red, so after resizing, MAE should be ~0
        #expect(result.mae < 1.0)
    }

    @Test("resizeToSmallest produces near-zero MAE for identical solid colors at different sizes")
    func resizeToSmallestSolidColor() throws {
        let small = solidImage(red: 0, green: 128, blue: 255, alpha: 255, width: 2, height: 2)
        let large = solidImage(red: 0, green: 128, blue: 255, alpha: 255, width: 6, height: 6)
        let options = ComparisonOptions(dimensionMismatch: .resizeToSmallest)

        let result = try ImageComparator.compare(small, large, options: options)

        #expect(result.mae < 1.0)
    }

    // MARK: - Helpers

    private func solidImage(
        red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8,
        width: Int, height: Int,
    ) -> PixelImage {
        let pixelCount = width * height
        var pixels = [UInt8](repeating: 0, count: pixelCount * 4)
        for i in 0 ..< pixelCount {
            pixels[i * 4 + 0] = red
            pixels[i * 4 + 1] = green
            pixels[i * 4 + 2] = blue
            pixels[i * 4 + 3] = alpha
        }
        return PixelImage(width: width, height: height, pixels: pixels)
    }
}
