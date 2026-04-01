public extension PixelImage {
    /// Returns a visual diff image highlighting per-pixel differences with another image.
    ///
    /// Each pixel in the result contains `abs(a - b) * intensity` for the red, green, and blue
    /// channels, clamped to 0–255. The alpha channel is always set to 255.
    ///
    /// - Parameters:
    ///   - other: The image to compare against. Must have the same dimensions.
    ///   - intensity: A multiplier for the difference values (default 1.0).
    /// - Returns: A new ``PixelImage`` visualizing the differences.
    /// - Throws: ``PixelPeeperError/dimensionMismatch(width1:height1:width2:height2:)``
    ///   if the images have different dimensions.
    func diff(with other: PixelImage, intensity: Double) throws -> PixelImage {
        guard width == other.width, height == other.height else {
            throw PixelPeeperError.dimensionMismatch(
                width1: width, height1: height,
                width2: other.width, height2: other.height,
            )
        }

        var diffPixels = [UInt8](repeating: 0, count: pixels.count)
        let pixelCount = width * height

        for i in 0 ..< pixelCount {
            let offset = i * 4
            for channel in 0 ..< 3 {
                let a = Int(pixels[offset + channel])
                let b = Int(other.pixels[offset + channel])
                let rawDiff = Double(abs(a - b)) * intensity
                diffPixels[offset + channel] = UInt8(min(255, Int(rawDiff)))
            }
            diffPixels[offset + 3] = 255
        }

        return PixelImage(width: width, height: height, pixels: diffPixels)
    }
}
