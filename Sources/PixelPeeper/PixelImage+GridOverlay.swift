public extension PixelImage {
    /// Returns a new image with a grid overlay drawn at the given spacing.
    ///
    /// Pixels where `x % spacing == 0` or `y % spacing == 0` are replaced with the grid color.
    /// All other pixels retain their original color.
    ///
    /// - Parameters:
    ///   - spacing: The distance in pixels between grid lines.
    ///   - color: The color to use for grid lines.
    /// - Returns: A new ``PixelImage`` with the grid overlay applied.
    func withGridOverlay(spacing: Int, color: PixelColor) -> PixelImage {
        var newPixels = pixels

        for y in 0 ..< height {
            for x in 0 ..< width {
                if x % spacing == 0 || y % spacing == 0 {
                    let offset = (y * width + x) * 4
                    newPixels[offset] = color.red
                    newPixels[offset + 1] = color.green
                    newPixels[offset + 2] = color.blue
                    newPixels[offset + 3] = color.alpha
                }
            }
        }

        return PixelImage(width: width, height: height, pixels: newPixels)
    }
}
