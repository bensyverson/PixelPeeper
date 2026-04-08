import CoreGraphics

extension PixelImage {
    /// Creates a pixel image by extracting RGBA pixel data from a `CGImage`.
    ///
    /// The image is drawn into an sRGB context with 8 bits per component, premultiplied alpha,
    /// and big-endian byte order (RGBA layout) — the same format used by ``load(from:)``.
    ///
    /// - Parameter cgImage: The Core Graphics image to extract pixels from.
    /// - Throws: ``PixelPeeperError/cgImageExtractionFailed`` if the bitmap context cannot be created.
    public init(cgImage: CGImage) throws {
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
            throw PixelPeeperError.cgImageExtractionFailed
        }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        self.init(width: width, height: height, pixels: pixels)
    }
}
