import CoreGraphics
@testable import PixelPeeper
import Testing

@Suite("PixelImage outlines")
struct PixelImageOutlinesTests {
    static let white = PixelColor(red: 255, green: 255, blue: 255, alpha: 255)
    static let red = PixelColor(red: 255, green: 0, blue: 0, alpha: 255)

    static func blank(_ size: Int) -> PixelImage {
        PixelImage(
            width: size, height: size,
            pixels: [UInt8](repeating: 255, count: size * size * 4),
        )
    }

    // MARK: - Pixel rect

    @Test
    func `a source rect scales and shifts into image pixels`() {
        let outline = Outline(rect: CGRect(x: 5, y: 5, width: 10, height: 10))

        #expect(outline.pixelRect(pixelsPerPoint: 2) == CGRect(x: 10, y: 10, width: 20, height: 20))
        #expect(outline.pixelRect(pixelsPerPoint: 2, origin: CGPoint(x: 2, y: 2))
            == CGRect(x: 6, y: 6, width: 20, height: 20))
        #expect(outline.pixelRect(pixelsPerPoint: 1) == CGRect(x: 5, y: 5, width: 10, height: 10))
    }

    @Test
    func `an outline defaults to a 2 px ring with no colour and no label`() {
        let outline = Outline(rect: CGRect(x: 0, y: 0, width: 1, height: 1))

        #expect(outline.color == nil)
        #expect(outline.label == nil)
        #expect(outline.width == 2)
    }

    // MARK: - Stroke placement

    @Test
    func `the ring lies wholly outside the rect`() throws {
        let outline = Outline(
            rect: CGRect(x: 5, y: 5, width: 10, height: 10), color: Self.red, width: 2,
        )
        let result = try Self.blank(20).withOutlines([outline], pixelsPerPoint: 1)

        #expect(result.width == 20)
        #expect(result.height == 20)

        // The rect's own edge pixels are untouched.
        #expect(try result.color(atX: 5, y: 5) == Self.white)
        #expect(try result.color(atX: 14, y: 14) == Self.white)
        #expect(try result.color(atX: 10, y: 10) == Self.white)

        // The two pixels immediately outside each edge carry the ring.
        #expect(try result.color(atX: 4, y: 5) == Self.red)
        #expect(try result.color(atX: 3, y: 5) == Self.red)
        #expect(try result.color(atX: 15, y: 5) == Self.red)
        #expect(try result.color(atX: 16, y: 5) == Self.red)
        #expect(try result.color(atX: 5, y: 4) == Self.red)
        #expect(try result.color(atX: 5, y: 16) == Self.red)

        // …and nothing beyond it.
        #expect(try result.color(atX: 2, y: 5) == Self.white)
        #expect(try result.color(atX: 17, y: 5) == Self.white)
        #expect(try result.color(atX: 5, y: 2) == Self.white)
        #expect(try result.color(atX: 5, y: 17) == Self.white)
    }

    @Test
    func `the ring follows the scale`() throws {
        let outline = Outline(
            rect: CGRect(x: 5, y: 5, width: 10, height: 10), color: Self.red, width: 2,
        )
        let result = try Self.blank(40).withOutlines([outline], pixelsPerPoint: 2)

        #expect(try result.color(atX: 10, y: 10) == Self.white)
        #expect(try result.color(atX: 9, y: 10) == Self.red)
        #expect(try result.color(atX: 8, y: 10) == Self.red)
        #expect(try result.color(atX: 7, y: 10) == Self.white)
        #expect(try result.color(atX: 30, y: 10) == Self.red)
        #expect(try result.color(atX: 29, y: 10) == Self.white)
    }

    @Test
    func `a crop origin shifts the ring, and the part off-image is clipped`() throws {
        let outline = Outline(
            rect: CGRect(x: 5, y: 5, width: 10, height: 10), color: Self.red, width: 2,
        )
        let result = try Self.blank(20).withOutlines(
            [outline], pixelsPerPoint: 1, origin: CGPoint(x: 5, y: 5),
        )

        // The rect now starts at the image's top-left; its top and left ring fall off-image.
        #expect(try result.color(atX: 0, y: 0) == Self.white)
        #expect(try result.color(atX: 9, y: 9) == Self.white)
        #expect(try result.color(atX: 10, y: 5) == Self.red)
        #expect(try result.color(atX: 11, y: 5) == Self.red)
        #expect(try result.color(atX: 12, y: 5) == Self.white)
    }

    // MARK: - Default two-tone colour

    @Test
    func `the default ring is two-tone so it reads on light and dark alike`() throws {
        let outline = Outline(rect: CGRect(x: 5, y: 5, width: 10, height: 10), width: 2)
        let result = try Self.blank(20).withOutlines([outline], pixelsPerPoint: 1)

        let inner = try result.color(atX: 4, y: 5)
        let outer = try result.color(atX: 3, y: 5)

        #expect(try result.color(atX: 5, y: 5) == Self.white)
        #expect(inner != outer)
        #expect(inner.red < 64)
        #expect(outer.red > 192)
        #expect(try result.color(atX: 2, y: 5) == Self.white)
    }

    // MARK: - Labels

    @Test
    func `a labelled outline draws a tag above the rect`() throws {
        let outline = Outline(
            rect: CGRect(x: 5, y: 40, width: 10, height: 10), color: Self.red, label: "Header",
        )
        let result = try Self.blank(80).withOutlines([outline], pixelsPerPoint: 1)

        // Somewhere in the tag band above the rect is inked.
        let tagBand = try result.cropped(x: 0, y: 40 - 2 - OverlayStyle.tagHeight, width: 80, height: OverlayStyle.tagHeight)
        #expect(tagBand.pixels.contains { $0 != 255 })
        // Far from the outline, the image is untouched.
        #expect(try result.color(atX: 70, y: 70) == Self.white)
    }

    @Test
    func `a tag that would fall off the top is clamped inside the image`() throws {
        let outline = Outline(
            rect: CGRect(x: 0, y: 0, width: 10, height: 10), color: Self.red, label: "Header",
        )
        let result = try Self.blank(80).withOutlines([outline], pixelsPerPoint: 1)

        #expect(result.width == 80)
        #expect(result.height == 80)
        let topBand = try result.cropped(x: 0, y: 0, width: 80, height: OverlayStyle.tagHeight)
        #expect(topBand.pixels.contains { $0 != 255 })
    }

    // MARK: - Degenerate inputs

    @Test
    func `an empty outline list returns the image unchanged`() throws {
        let source = Self.blank(20)
        let result = try source.withOutlines([], pixelsPerPoint: 1)

        #expect(result.pixels == source.pixels)
    }

    @Test
    func `a non-positive scale is refused`() {
        #expect(throws: PixelPeeperError.invalidOverlayScale(-1)) {
            _ = try Self.blank(20).withOutlines([], pixelsPerPoint: -1)
        }
    }
}
