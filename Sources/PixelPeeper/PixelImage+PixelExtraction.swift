import CoreGraphics

extension PixelImage {
    /// Extracts raw RGBA pixel data from a `CGImage` by drawing it into a standardized context.
    ///
    /// The image is drawn into an sRGB context with 8 bits per component, premultiplied alpha,
    /// and big-endian byte order (RGBA layout).
    ///
    /// - Parameters:
    ///   - cgImage: The Core Graphics image to extract pixels from.
    ///   - sourcePath: The file path of the source image, used for error reporting.
    /// - Returns: A ``PixelImage`` containing the extracted pixel data.
    /// - Throws: ``PixelPeeperError/pixelExtractionFailed(path:)`` if the context cannot be created.
    static func extractPixels(from cgImage: CGImage, sourcePath: String) throws -> PixelImage {
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerRow = width * 4
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
            | CGBitmapInfo.byteOrder32Big.rawValue

        var pixels = [UInt8](repeating: 0, count: width * height * 4)

        guard let context = CGContext(
            data: &pixels, width: width, height: height,
            bitsPerComponent: 8, bytesPerRow: bytesPerRow,
            space: colorSpace, bitmapInfo: bitmapInfo
        ) else {
            throw PixelPeeperError.pixelExtractionFailed(path: sourcePath)
        }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        return PixelImage(width: width, height: height, pixels: pixels)
    }
}
