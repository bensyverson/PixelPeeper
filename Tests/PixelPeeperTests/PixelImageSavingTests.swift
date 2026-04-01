import Foundation
@testable import PixelPeeper
import Testing

@Suite("PixelImage saving")
struct PixelImageSavingTests {
    @Test("write and reload PNG produces identical pixel data")
    func writeReloadRoundTrip() throws {
        let original = PixelImage(width: 2, height: 2, pixels: [
            255, 0, 0, 255, 0, 255, 0, 255,
            0, 0, 255, 255, 255, 255, 255, 255,
        ])

        let url = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("PixelPeeper-test-\(UUID().uuidString).png")
        defer { try? FileManager.default.removeItem(at: url) }

        try original.writePNG(to: url)

        let reloaded = try PixelImage.load(from: url)

        #expect(reloaded.width == original.width)
        #expect(reloaded.height == original.height)
        #expect(reloaded.pixels == original.pixels)
    }

    @Test("written PNG file exists on disk")
    func fileExistsAfterWrite() throws {
        let image = PixelImage(width: 1, height: 1, pixels: [128, 64, 32, 255])

        let url = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("PixelPeeper-test-\(UUID().uuidString).png")
        defer { try? FileManager.default.removeItem(at: url) }

        try image.writePNG(to: url)

        #expect(FileManager.default.fileExists(atPath: url.path))
    }
}
