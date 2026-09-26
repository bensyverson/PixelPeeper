import CoreGraphics

extension PixelImage {
    /// Creates a pixel image by extracting RGBA pixel data from a `CGImage`.
    ///
    /// The image is drawn into an sRGB context with 8 bits per component, premultiplied alpha,
    /// and big-endian byte order (RGBA layout) — the same format used by ``load(from:scale:)``.
    ///
    /// - Parameter cgImage: The Core Graphics image to extract pixels from.
    /// - Throws: ``PixelPeeperError/cgImageExtractionFailed`` if the bitmap context cannot be created.
    public init(cgImage: CGImage) throws {
        try self.init(cgImage: cgImage, width: cgImage.width, height: cgImage.height)
    }

    /// Creates a pixel image by drawing a `CGImage` scaled to the given size.
    ///
    /// The whole image is drawn into a `width` × `height` sRGB context with 8 bits per
    /// component, premultiplied alpha and RGBA byte order, at Core Graphics' default
    /// interpolation quality. At the image's own size this is exactly ``init(cgImage:)``;
    /// at any other size the source is resampled once, as it is decoded — unlike
    /// ``resized(toWidth:height:)``, which resamples bytes already decoded to 8 bits.
    ///
    /// Use it to bring a render and a reference to one pixel grid before comparing them,
    /// such as a 2× render against a 1× reference.
    ///
    /// - Parameters:
    ///   - cgImage: The Core Graphics image to draw.
    ///   - width: The width of the resulting image, in pixels.
    ///   - height: The height of the resulting image, in pixels.
    /// - Throws: ``PixelPeeperError/cgImageExtractionFailed`` if the bitmap context cannot be
    ///   created, including when either dimension is zero.
    public init(cgImage: CGImage, width: Int, height: Int) throws {
        guard width > 0, height > 0 else {
            throw PixelPeeperError.cgImageExtractionFailed
        }
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
