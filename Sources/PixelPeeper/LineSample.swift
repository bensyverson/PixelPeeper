/// A single sample point along a line through an image, with its pixel coordinates and color.
public struct LineSample: Friendly {
    /// The horizontal coordinate of the sample point.
    public let x: Int

    /// The vertical coordinate of the sample point.
    public let y: Int

    /// The color of the pixel at this sample point.
    public let color: PixelColor

    /// Creates a line sample with the given coordinates and color.
    ///
    /// - Parameters:
    ///   - x: The horizontal coordinate.
    ///   - y: The vertical coordinate.
    ///   - color: The pixel color at this point.
    public init(x: Int, y: Int, color: PixelColor) {
        self.x = x
        self.y = y
        self.color = color
    }
}
