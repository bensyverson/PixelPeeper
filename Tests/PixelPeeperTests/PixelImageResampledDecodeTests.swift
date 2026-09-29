import CoreGraphics
import Foundation
@testable import PixelPeeper
import Testing

/// `PixelImage(cgImage:width:height:)` draws a `CGImage` scaled into a buffer of the
/// given size — resampling the source itself, once, as it is decoded.
@Suite("PixelImage decoded at a size")
struct PixelImageResampledDecodeTests {
    @Test("at the image's own size it decodes exactly as init(cgImage:) does")
    func nativeSizeMatchesPlainDecode() throws {
        let source = try cgImage(width: 3, height: 2, pixels: [
            255, 0, 0, 255, 0, 255, 0, 255, 0, 0, 255, 255,
            10, 20, 30, 255, 128, 128, 128, 128, 0, 0, 0, 0,
        ])

        let sized = try PixelImage(cgImage: source, width: 3, height: 2)

        #expect(sized == (try PixelImage(cgImage: source)))
    }

    @Test("a solid color keeps its color at a smaller size")
    func solidColorSurvivesDownscale() throws {
        let source = try cgImage(
            width: 4, height: 2,
            pixels: Array([[UInt8]](repeating: [0, 128, 255, 255], count: 8).joined()),
        )

        let sized = try PixelImage(cgImage: source, width: 2, height: 1)

        #expect(sized.width == 2)
        #expect(sized.height == 1)
        #expect(sized.pixels == [0, 128, 255, 255, 0, 128, 255, 255])
    }

    @Test("a smaller size resamples the whole image rather than cropping it")
    func resamplesNotCrops() throws {
        let source = try cgImage(width: 2, height: 1, pixels: [
            0, 0, 0, 255, 255, 255, 255, 255,
        ])

        let sized = try PixelImage(cgImage: source, width: 1, height: 1)

        // A crop would keep the black pixel; a resample lands between the two.
        #expect(sized.pixels[0] > 0 && sized.pixels[0] < 255)
    }

    @Test("the top of the source stays at the top of the buffer")
    func keepsOrientation() throws {
        let source = try cgImage(width: 2, height: 4, pixels: Array([
            [UInt8]](repeating: [255, 0, 0, 255], count: 4).joined()
        ) + Array([[UInt8]](repeating: [0, 0, 255, 255], count: 4).joined()))

        let sized = try PixelImage(cgImage: source, width: 1, height: 2)

        // Interpolation bleeds a little across the seam; the dominant channel says which
        // half landed where.
        #expect(sized.pixels[0] > 200 && sized.pixels[2] < 55)
        #expect(sized.pixels[4] < 55 && sized.pixels[6] > 200)
    }

    @Test("a zero-pixel size is refused")
    func zeroSizeThrows() throws {
        let source = try cgImage(width: 1, height: 1, pixels: [0, 0, 0, 255])

        #expect(throws: PixelPeeperError.cgImageExtractionFailed) {
            try PixelImage(cgImage: source, width: 0, height: 1)
        }
    }

    /// Builds a premultiplied sRGB `CGImage` from RGBA bytes.
    private func cgImage(width: Int, height: Int, pixels: [UInt8]) throws -> CGImage {
        var bytes = pixels
        let context = try #require(CGContext(
            data: &bytes, width: width, height: height, bitsPerComponent: 8,
            bytesPerRow: width * 4, space: CGColorSpace(name: CGColorSpace.sRGB)!,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue,
        ))
        return try #require(context.makeImage())
    }
}
