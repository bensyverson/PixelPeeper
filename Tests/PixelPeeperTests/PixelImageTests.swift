import Foundation
@testable import PixelPeeper
import Testing

@Suite("PixelImage")
struct PixelImageTests {
    // MARK: - Struct basics

    @Test("stores width, height, and pixel data")
    func storesValues() {
        // 1×1 red pixel: RGBA
        let pixels: [UInt8] = [255, 0, 0, 255]
        let image = PixelImage(width: 1, height: 1, pixels: pixels)

        #expect(image.width == 1)
        #expect(image.height == 1)
        #expect(image.pixels == pixels)
    }

    @Test("pixelCount returns width times height")
    func pixelCount() {
        let pixels = [UInt8](repeating: 0, count: 3 * 2 * 4)
        let image = PixelImage(width: 3, height: 2, pixels: pixels)

        #expect(image.pixelCount == 6)
    }

    @Test("conforms to Equatable")
    func equatable() {
        let a = PixelImage(width: 1, height: 1, pixels: [255, 0, 0, 255])
        let b = PixelImage(width: 1, height: 1, pixels: [255, 0, 0, 255])
        let c = PixelImage(width: 1, height: 1, pixels: [0, 0, 255, 255])

        #expect(a == b)
        #expect(a != c)
    }

    @Test("round-trips through JSON encoding and decoding")
    func codableRoundTrip() throws {
        let original = PixelImage(width: 1, height: 1, pixels: [128, 64, 32, 255])

        let data = try JSONEncoder().encode(original)
        let decoded: PixelImage = try JSONDecoder().decode(PixelImage.self, from: data)

        #expect(decoded == original)
    }

    // MARK: - Loading from file

    @Test("loads a 2×2 solid red PNG with correct dimensions and pixel values")
    func loadRedFixture() throws {
        let url = fixtureURL(named: "red-2x2")
        let image = try PixelImage.load(from: url)

        #expect(image.width == 2)
        #expect(image.height == 2)
        #expect(image.pixelCount == 4)

        // Every pixel should be red (255, 0, 0, 255)
        for i in 0 ..< image.pixelCount {
            let offset = i * 4
            #expect(image.pixels[offset] == 255, "Red channel of pixel \(i)")
            #expect(image.pixels[offset + 1] == 0, "Green channel of pixel \(i)")
            #expect(image.pixels[offset + 2] == 0, "Blue channel of pixel \(i)")
            #expect(image.pixels[offset + 3] == 255, "Alpha channel of pixel \(i)")
        }
    }

    @Test("loads a 2×2 solid blue PNG with correct pixel values")
    func loadBlueFixture() throws {
        let url = fixtureURL(named: "blue-2x2")
        let image = try PixelImage.load(from: url)

        #expect(image.width == 2)
        #expect(image.height == 2)

        for i in 0 ..< image.pixelCount {
            let offset = i * 4
            #expect(image.pixels[offset] == 0, "Red channel of pixel \(i)")
            #expect(image.pixels[offset + 1] == 0, "Green channel of pixel \(i)")
            #expect(image.pixels[offset + 2] == 255, "Blue channel of pixel \(i)")
            #expect(image.pixels[offset + 3] == 255, "Alpha channel of pixel \(i)")
        }
    }

    @Test("throws fileNotFound for a nonexistent path")
    func loadMissingFile() {
        let url = URL(fileURLWithPath: "/tmp/nonexistent-\(UUID()).png")

        #expect(throws: PixelPeeperError.self) {
            try PixelImage.load(from: url)
        }
    }

    @Test("throws imageLoadFailed for an invalid image file")
    func loadInvalidFile() throws {
        let url = URL(fileURLWithPath: "/tmp/not-an-image-\(UUID()).png")
        try "this is not an image".write(to: url, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: url) }

        #expect(throws: PixelPeeperError.self) {
            try PixelImage.load(from: url)
        }
    }

    // MARK: - PDF loading

    @Test("loads a solid red PDF and extracts pixel data")
    func loadPDFFixture() throws {
        let url = fixtureURL(named: "red-100x100", extension: "pdf")
        let image = try PixelImage.load(from: url)

        // PDF is 100×100 pt, default scale is 2x → 200×200 px
        #expect(image.width == 200)
        #expect(image.height == 200)

        // Sample a few pixels — should be solid red
        for i in [0, 100, 39999] {
            let offset = i * 4
            #expect(image.pixels[offset] == 255, "Red channel of pixel \(i)")
            #expect(image.pixels[offset + 1] == 0, "Green channel of pixel \(i)")
            #expect(image.pixels[offset + 2] == 0, "Blue channel of pixel \(i)")
            #expect(image.pixels[offset + 3] == 255, "Alpha channel of pixel \(i)")
        }
    }

    @Test("loads a PDF at custom scale")
    func loadPDFAtCustomScale() throws {
        let url = fixtureURL(named: "red-100x100", extension: "pdf")
        let image = try PixelImage.load(from: url, scale: 1)

        // 100×100 pt at 1x → 100×100 px
        #expect(image.width == 100)
        #expect(image.height == 100)
    }

    @Test("scale parameter does not affect bitmap loading")
    func scaleIgnoredForBitmaps() throws {
        let url = fixtureURL(named: "red-2x2", extension: "png")
        let image = try PixelImage.load(from: url, scale: 4)

        // Bitmap dimensions are unchanged regardless of scale
        #expect(image.width == 2)
        #expect(image.height == 2)
    }

    // MARK: - Helpers

    private func fixtureURL(named name: String, extension ext: String = "png") -> URL {
        Bundle.module.url(forResource: name, withExtension: ext, subdirectory: "Fixtures")!
    }
}
