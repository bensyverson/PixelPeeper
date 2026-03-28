import CoreGraphics

extension PixelImage {
    /// Returns a new image resized to the given dimensions using bilinear interpolation.
    ///
    /// The pixel data is reconstructed into a `CGImage`, drawn into a new context at the
    /// target size (which applies bilinear interpolation), and then re-extracted.
    ///
    /// - Parameters:
    ///   - targetWidth: The desired width in pixels.
    ///   - targetHeight: The desired height in pixels.
    /// - Returns: A new ``PixelImage`` at the target dimensions.
    /// - Throws: ``PixelPeeperError/pixelExtractionFailed(path:)`` if the resize operation fails.
    func resized(toWidth targetWidth: Int, height targetHeight: Int) throws -> PixelImage {
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
            | CGBitmapInfo.byteOrder32Big.rawValue

        // Reconstruct a CGImage from our pixel data
        var sourcePixels = pixels
        guard let sourceContext = CGContext(
            data: &sourcePixels, width: width, height: height,
            bitsPerComponent: 8, bytesPerRow: width * 4,
            space: colorSpace, bitmapInfo: bitmapInfo
        ), let cgImage = sourceContext.makeImage() else {
            throw PixelPeeperError.pixelExtractionFailed(path: "<resize>")
        }

        // Draw into a new context at the target size
        let targetBytesPerRow = targetWidth * 4
        var targetPixels = [UInt8](repeating: 0, count: targetWidth * targetHeight * 4)

        guard let targetContext = CGContext(
            data: &targetPixels, width: targetWidth, height: targetHeight,
            bitsPerComponent: 8, bytesPerRow: targetBytesPerRow,
            space: colorSpace, bitmapInfo: bitmapInfo
        ) else {
            throw PixelPeeperError.pixelExtractionFailed(path: "<resize>")
        }

        targetContext.interpolationQuality = .high
        targetContext.draw(cgImage, in: CGRect(x: 0, y: 0, width: targetWidth, height: targetHeight))

        return PixelImage(width: targetWidth, height: targetHeight, pixels: targetPixels)
    }
}
