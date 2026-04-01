import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

public extension PixelImage {
    /// Writes the image as a PNG file to the given URL.
    ///
    /// Reconstructs a `CGImage` from the raw pixel data and writes it using ImageIO.
    ///
    /// - Parameter url: The file URL to write the PNG to.
    /// - Throws: ``PixelPeeperError/pixelExtractionFailed(path:)`` if the image data
    ///   cannot be converted to a `CGImage`.
    func writePNG(to url: URL) throws {
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
            | CGBitmapInfo.byteOrder32Big.rawValue

        var pixelsCopy = pixels
        guard let context = CGContext(
            data: &pixelsCopy, width: width, height: height,
            bitsPerComponent: 8, bytesPerRow: width * 4,
            space: colorSpace, bitmapInfo: bitmapInfo,
        ), let cgImage = context.makeImage() else {
            throw PixelPeeperError.pixelExtractionFailed(path: url.path)
        }

        guard let destination = CGImageDestinationCreateWithURL(
            url as CFURL, UTType.png.identifier as CFString, 1, nil,
        ) else {
            throw PixelPeeperError.pixelExtractionFailed(path: url.path)
        }

        CGImageDestinationAddImage(destination, cgImage, nil)

        guard CGImageDestinationFinalize(destination) else {
            throw PixelPeeperError.pixelExtractionFailed(path: url.path)
        }
    }
}
