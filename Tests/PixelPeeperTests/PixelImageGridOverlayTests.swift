@testable import PixelPeeper
import Testing

@Suite("PixelImage grid overlay")
struct PixelImageGridOverlayTests {
    static let red = PixelColor(red: 255, green: 0, blue: 0, alpha: 255)
    static let green = PixelColor(red: 0, green: 255, blue: 0, alpha: 255)

    /// 4x4 solid red image
    static let testImage = PixelImage(
        width: 4, height: 4,
        pixels: [UInt8](repeating: 0, count: 4 * 4 * 4).enumerated().map { i, _ in
            switch i % 4 {
            case 0: 255
            case 3: 255
            default: 0
            }
        },
    )

    @Test("grid lines appear at multiples of spacing")
    func gridLinesAtSpacingMultiples() throws {
        let result = Self.testImage.withGridOverlay(spacing: 2, color: Self.green)

        // (0,0) is on grid (0 % 2 == 0)
        #expect(try result.color(atX: 0, y: 0) == Self.green)
        // (2,0) is on grid
        #expect(try result.color(atX: 2, y: 0) == Self.green)
        // (0,2) is on grid
        #expect(try result.color(atX: 0, y: 2) == Self.green)
        // (1,1) is not on grid
        #expect(try result.color(atX: 1, y: 1) == Self.red)
        // (3,3) is not on grid
        #expect(try result.color(atX: 3, y: 3) == Self.red)
    }

    @Test("preserves image dimensions")
    func preservesDimensions() {
        let result = Self.testImage.withGridOverlay(spacing: 2, color: Self.green)

        #expect(result.width == Self.testImage.width)
        #expect(result.height == Self.testImage.height)
    }

    @Test("spacing of 1 replaces all pixels with grid color")
    func spacingOneReplacesAll() throws {
        let result = Self.testImage.withGridOverlay(spacing: 1, color: Self.green)

        for y in 0 ..< result.height {
            for x in 0 ..< result.width {
                #expect(try result.color(atX: x, y: y) == Self.green)
            }
        }
    }

    @Test("non-grid pixels retain original color")
    func nonGridPixelsRetainColor() throws {
        let result = Self.testImage.withGridOverlay(spacing: 4, color: Self.green)

        // Only x=0 or y=0 are grid lines with spacing 4 in a 4x4 image
        // (1,1) should be original red
        #expect(try result.color(atX: 1, y: 1) == Self.red)
        // (2,3) should be original red
        #expect(try result.color(atX: 2, y: 3) == Self.red)
    }
}
