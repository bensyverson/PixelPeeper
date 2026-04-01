public extension PixelImage {
    /// The color of the pixel at the given coordinates.
    ///
    /// Coordinates are 0-indexed from the top-left corner of the image.
    ///
    /// - Parameters:
    ///   - x: The horizontal coordinate (0-indexed from left).
    ///   - y: The vertical coordinate (0-indexed from top).
    /// - Returns: The ``PixelColor`` at the specified position.
    /// - Throws: ``PixelPeeperError/coordinateOutOfBounds(x:y:width:height:)``
    ///   if the coordinates are outside the image bounds.
    func color(atX x: Int, y: Int) throws -> PixelColor {
        guard x >= 0, x < width, y >= 0, y < height else {
            throw PixelPeeperError.coordinateOutOfBounds(
                x: x, y: y, width: width, height: height,
            )
        }

        let offset = (y * width + x) * 4
        return PixelColor(
            red: pixels[offset],
            green: pixels[offset + 1],
            blue: pixels[offset + 2],
            alpha: pixels[offset + 3],
        )
    }
}
