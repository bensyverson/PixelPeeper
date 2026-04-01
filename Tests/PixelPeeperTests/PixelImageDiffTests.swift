@testable import PixelPeeper
import Testing

@Suite("PixelImage diff")
struct PixelImageDiffTests {
    @Test("identical images produce black diff")
    func identicalImagesProduceBlackDiff() throws {
        let image = PixelImage(width: 2, height: 1, pixels: [
            255, 0, 0, 255, 0, 255, 0, 255,
        ])

        let result = try image.diff(with: image, intensity: 1.0)

        #expect(result.width == 2)
        #expect(result.height == 1)
        // All differences are 0, alpha is always 255
        #expect(result.pixels == [0, 0, 0, 255, 0, 0, 0, 255])
    }

    @Test("maximally different pixels produce white diff at intensity 1")
    func maxDifferenceProducesWhite() throws {
        let black = PixelImage(width: 1, height: 1, pixels: [0, 0, 0, 255])
        let white = PixelImage(width: 1, height: 1, pixels: [255, 255, 255, 255])

        let result = try black.diff(with: white, intensity: 1.0)

        #expect(result.pixels == [255, 255, 255, 255])
    }

    @Test("intensity multiplies the difference")
    func intensityMultipliesDifference() throws {
        let a = PixelImage(width: 1, height: 1, pixels: [0, 0, 0, 255])
        let b = PixelImage(width: 1, height: 1, pixels: [100, 50, 25, 255])

        let result = try a.diff(with: b, intensity: 2.0)

        // 100*2=200, 50*2=100, 25*2=50, alpha always 255
        #expect(result.pixels == [200, 100, 50, 255])
    }

    @Test("intensity clamps values to 255")
    func intensityClampsTo255() throws {
        let a = PixelImage(width: 1, height: 1, pixels: [0, 0, 0, 255])
        let b = PixelImage(width: 1, height: 1, pixels: [200, 200, 200, 255])

        let result = try a.diff(with: b, intensity: 2.0)

        // 200*2=400 clamped to 255
        #expect(result.pixels == [255, 255, 255, 255])
    }

    @Test("diff ignores alpha channel differences")
    func ignoresAlphaChannelDifferences() throws {
        let a = PixelImage(width: 1, height: 1, pixels: [100, 100, 100, 0])
        let b = PixelImage(width: 1, height: 1, pixels: [100, 100, 100, 255])

        let result = try a.diff(with: b, intensity: 1.0)

        // RGB diffs are 0, alpha is always 255
        #expect(result.pixels == [0, 0, 0, 255])
    }

    @Test("throws dimensionMismatch for different-sized images")
    func throwsForDimensionMismatch() {
        let a = PixelImage(width: 2, height: 2, pixels: [UInt8](repeating: 0, count: 16))
        let b = PixelImage(width: 3, height: 3, pixels: [UInt8](repeating: 0, count: 36))

        #expect(throws: PixelPeeperError.self) {
            try a.diff(with: b, intensity: 1.0)
        }
    }
}
