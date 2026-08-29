import CoreGraphics
@testable import PixelPeeper
import Testing

@Suite("PixelImage labels")
struct PixelImageLabelsTests {
    static let white = PixelColor(red: 255, green: 255, blue: 255, alpha: 255)

    static func blank(_ size: Int) -> PixelImage {
        PixelImage(
            width: size, height: size,
            pixels: [UInt8](repeating: 255, count: size * size * 4),
        )
    }

    @Test
    func `a label defaults to the standard tag colour`() {
        let label = OverlayLabel(text: "42", position: CGPoint(x: 1, y: 2))

        #expect(label.text == "42")
        #expect(label.position == CGPoint(x: 1, y: 2))
        #expect(label.color == nil)
    }

    @Test
    func `a tag is drawn with its top-left at the label's source position`() throws {
        let result = try Self.blank(40).withLabels(
            [OverlayLabel(text: "42", position: CGPoint(x: 10, y: 10))], pixelsPerPoint: 1,
        )

        #expect(result.width == 40)
        #expect(result.height == 40)
        #expect(try result.color(atX: 11, y: 11) != Self.white)
        #expect(try result.color(atX: 0, y: 0) == Self.white)
        #expect(try result.color(atX: 39, y: 39) == Self.white)
    }

    @Test
    func `the position is in source units, so scale 2 doubles the pixel offset`() throws {
        let result = try Self.blank(60).withLabels(
            [OverlayLabel(text: "42", position: CGPoint(x: 10, y: 10))], pixelsPerPoint: 2,
        )

        #expect(try result.color(atX: 11, y: 11) == Self.white)
        #expect(try result.color(atX: 21, y: 21) != Self.white)
    }

    @Test
    func `a crop origin is subtracted from the position`() throws {
        let result = try Self.blank(40).withLabels(
            [OverlayLabel(text: "42", position: CGPoint(x: 910, y: 910))],
            pixelsPerPoint: 1, origin: CGPoint(x: 900, y: 900),
        )

        #expect(try result.color(atX: 11, y: 11) != Self.white)
    }

    @Test
    func `a tag near the edge is clamped inside the image`() throws {
        let result = try Self.blank(40).withLabels(
            [OverlayLabel(text: "12345", position: CGPoint(x: 39, y: 39))], pixelsPerPoint: 1,
        )

        #expect(result.width == 40)
        #expect(result.height == 40)
        let bottomRight = try result.cropped(x: 20, y: 40 - OverlayStyle.tagHeight, width: 20, height: OverlayStyle.tagHeight)
        #expect(bottomRight.pixels.contains { $0 != 255 })
    }

    @Test
    func `an empty label list returns the image unchanged`() throws {
        let source = Self.blank(20)
        let result = try source.withLabels([], pixelsPerPoint: 1)

        #expect(result.pixels == source.pixels)
    }

    @Test
    func `a non-positive scale is refused`() {
        #expect(throws: PixelPeeperError.invalidOverlayScale(0)) {
            _ = try Self.blank(20).withLabels([], pixelsPerPoint: 0)
        }
    }
}
