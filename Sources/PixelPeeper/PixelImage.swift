/// A loaded image represented as raw RGBA pixel data.
///
/// Pixel data is stored in row-major order with 4 bytes per pixel (red, green, blue, alpha),
/// using the sRGB color space with premultiplied alpha.
///
/// Create a `PixelImage` by loading from a file with ``load(from:)`` or by
/// providing pixel data directly.
public struct PixelImage: Friendly {
    /// The width of the image in pixels.
    public let width: Int

    /// The height of the image in pixels.
    public let height: Int

    /// Raw RGBA pixel data, 4 bytes per pixel, in row-major order.
    public let pixels: [UInt8]

    /// The total number of pixels in the image.
    public var pixelCount: Int {
        width * height
    }

    /// Creates a pixel image with the given dimensions and pixel data.
    ///
    /// - Parameters:
    ///   - width: The width of the image in pixels.
    ///   - height: The height of the image in pixels.
    ///   - pixels: Raw RGBA pixel data. Must contain exactly `width × height × 4` bytes.
    public init(width: Int, height: Int, pixels: [UInt8]) {
        self.width = width
        self.height = height
        self.pixels = pixels
    }
}
