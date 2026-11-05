@testable import PixelPeeper
import Testing

@Suite("PixelImage cropping")
struct PixelImageCroppingTests {
    /// A 3x3 image with distinct pixel colors for each position
    static let testImage: PixelImage = {
        var pixels = [UInt8]()
        for row in 0 ..< 3 {
            for col in 0 ..< 3 {
                let value = UInt8(row * 3 + col) * 28 // 0, 28, 56, 84, ...
                pixels.append(contentsOf: [value, value, value, 255])
            }
        }
        return PixelImage(width: 3, height: 3, pixels: pixels)
    }()

    @Test
    func `crops full image returns identical image`() throws {
        let cropped = try Self.testImage.cropped(x: 0, y: 0, width: 3, height: 3)

        #expect(cropped.width == 3)
        #expect(cropped.height == 3)
        #expect(cropped.pixels == Self.testImage.pixels)
    }

    @Test
    func `crops single pixel at origin`() throws {
        let cropped = try Self.testImage.cropped(x: 0, y: 0, width: 1, height: 1)

        #expect(cropped.width == 1)
        #expect(cropped.height == 1)
        #expect(cropped.pixels == [0, 0, 0, 255])
    }

    @Test
    func `crops single pixel at bottom-right`() throws {
        let cropped = try Self.testImage.cropped(x: 2, y: 2, width: 1, height: 1)

        #expect(cropped.width == 1)
        #expect(cropped.height == 1)
        // Value at (2,2) = (2*3 + 2) * 28 = 224
        #expect(cropped.pixels == [224, 224, 224, 255])
    }

    @Test
    func `crops a 2x2 region from center`() throws {
        let cropped = try Self.testImage.cropped(x: 1, y: 1, width: 2, height: 2)

        #expect(cropped.width == 2)
        #expect(cropped.height == 2)
        // (1,1)=4*28=112, (2,1)=5*28=140, (1,2)=7*28=196, (2,2)=8*28=224
        let expected: [UInt8] = [
            112, 112, 112, 255, 140, 140, 140, 255,
            196, 196, 196, 255, 224, 224, 224, 255,
        ]
        #expect(cropped.pixels == expected)
    }

    @Test
    func `clips region that extends beyond image bounds`() throws {
        let cropped = try Self.testImage.cropped(x: 2, y: 2, width: 5, height: 5)

        #expect(cropped.width == 1)
        #expect(cropped.height == 1)
    }

    @Test
    func `throws invalidCropRegion when region is entirely outside bounds`() {
        #expect(throws: PixelPeeperError.self) {
            try Self.testImage.cropped(x: 5, y: 5, width: 2, height: 2)
        }
    }

    @Test
    func `throws invalidCropRegion for zero-size region`() {
        #expect(throws: PixelPeeperError.self) {
            try Self.testImage.cropped(x: 0, y: 0, width: 0, height: 1)
        }
    }

    @Test
    func `throws invalidCropRegion for negative dimensions`() {
        #expect(throws: PixelPeeperError.self) {
            try Self.testImage.cropped(x: 0, y: 0, width: -1, height: 1)
        }
    }
}
