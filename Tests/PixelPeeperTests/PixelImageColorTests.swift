import Foundation
@testable import PixelPeeper
import Testing

@Suite("PixelImage color sampling")
struct PixelImageColorTests {
    @Test("returns color of pixel at given coordinates")
    func colorAtCoordinates() throws {
        // 2×2 image: red, green, blue, white
        let pixels: [UInt8] = [
            255, 0, 0, 255, // (0,0) red
            0, 255, 0, 255, // (1,0) green
            0, 0, 255, 255, // (0,1) blue
            255, 255, 255, 255, // (1,1) white
        ]
        let image = PixelImage(width: 2, height: 2, pixels: pixels)

        let red = try image.color(atX: 0, y: 0)
        #expect(red == PixelColor(red: 255, green: 0, blue: 0, alpha: 255))

        let green = try image.color(atX: 1, y: 0)
        #expect(green == PixelColor(red: 0, green: 255, blue: 0, alpha: 255))

        let blue = try image.color(atX: 0, y: 1)
        #expect(blue == PixelColor(red: 0, green: 0, blue: 255, alpha: 255))

        let white = try image.color(atX: 1, y: 1)
        #expect(white == PixelColor(red: 255, green: 255, blue: 255, alpha: 255))
    }

    @Test("returns color from a loaded fixture image")
    func colorFromFixture() throws {
        let url = try #require(Bundle.module.url(forResource: "red-2x2", withExtension: "png", subdirectory: "Fixtures"))
        let image = try PixelImage.load(from: url)

        let color = try image.color(atX: 0, y: 0)
        #expect(color == PixelColor(red: 255, green: 0, blue: 0, alpha: 255))
    }

    @Test("throws coordinateOutOfBounds for negative x")
    func outOfBoundsNegativeX() {
        let image = PixelImage(width: 2, height: 2, pixels: [UInt8](repeating: 0, count: 16))

        #expect(throws: PixelPeeperError.coordinateOutOfBounds(x: -1, y: 0, width: 2, height: 2)) {
            try image.color(atX: -1, y: 0)
        }
    }

    @Test("throws coordinateOutOfBounds for x at width boundary")
    func outOfBoundsXAtWidth() {
        let image = PixelImage(width: 2, height: 2, pixels: [UInt8](repeating: 0, count: 16))

        #expect(throws: PixelPeeperError.coordinateOutOfBounds(x: 2, y: 0, width: 2, height: 2)) {
            try image.color(atX: 2, y: 0)
        }
    }

    @Test("throws coordinateOutOfBounds for negative y")
    func outOfBoundsNegativeY() {
        let image = PixelImage(width: 2, height: 2, pixels: [UInt8](repeating: 0, count: 16))

        #expect(throws: PixelPeeperError.coordinateOutOfBounds(x: 0, y: -1, width: 2, height: 2)) {
            try image.color(atX: 0, y: -1)
        }
    }

    @Test("throws coordinateOutOfBounds for y at height boundary")
    func outOfBoundsYAtHeight() {
        let image = PixelImage(width: 2, height: 2, pixels: [UInt8](repeating: 0, count: 16))

        #expect(throws: PixelPeeperError.coordinateOutOfBounds(x: 0, y: 2, width: 2, height: 2)) {
            try image.color(atX: 0, y: 2)
        }
    }
}
