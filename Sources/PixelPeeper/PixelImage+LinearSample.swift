import Foundation

public extension PixelImage {
    /// Samples pixel colors at evenly spaced points along a line between two coordinates.
    ///
    /// The line is interpolated from `from` to `to` with the given number of steps,
    /// including both endpoints. Each intermediate coordinate is rounded to the nearest pixel.
    ///
    /// - Parameters:
    ///   - from: The starting pixel coordinate as `(x: Int, y: Int)`.
    ///   - to: The ending pixel coordinate as `(x: Int, y: Int)`.
    ///   - steps: The number of sample points (must be at least 2).
    /// - Returns: An array of ``LineSample`` values from start to end.
    /// - Throws: ``PixelPeeperError/invalidStepCount(_:)`` if steps is less than 2.
    /// - Throws: ``PixelPeeperError/coordinateOutOfBounds(x:y:width:height:)``
    ///   if either endpoint is outside the image bounds.
    func linearSample(
        from: (x: Int, y: Int),
        to: (x: Int, y: Int),
        steps: Int,
    ) throws -> [LineSample] {
        guard steps >= 2 else {
            throw PixelPeeperError.invalidStepCount(steps)
        }

        // Validate endpoints are in bounds
        guard from.x >= 0, from.x < width, from.y >= 0, from.y < height else {
            throw PixelPeeperError.coordinateOutOfBounds(
                x: from.x, y: from.y, width: width, height: height,
            )
        }
        guard to.x >= 0, to.x < width, to.y >= 0, to.y < height else {
            throw PixelPeeperError.coordinateOutOfBounds(
                x: to.x, y: to.y, width: width, height: height,
            )
        }

        var samples = [LineSample]()
        samples.reserveCapacity(steps)

        for i in 0 ..< steps {
            let t = Double(i) / Double(steps - 1)
            let sampleX = Int((Double(from.x) + t * Double(to.x - from.x)).rounded())
            let sampleY = Int((Double(from.y) + t * Double(to.y - from.y)).rounded())
            let pixelColor = try color(atX: sampleX, y: sampleY)
            samples.append(LineSample(x: sampleX, y: sampleY, color: pixelColor))
        }

        return samples
    }
}
