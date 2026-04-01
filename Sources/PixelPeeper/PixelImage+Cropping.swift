public extension PixelImage {
    /// Returns a new image cropped to the given region.
    ///
    /// If the requested region extends beyond the image bounds, it is clipped to fit.
    /// The method throws if the resulting region has zero area (e.g., the crop rectangle
    /// is entirely outside the image, or zero/negative dimensions are provided).
    ///
    /// - Parameters:
    ///   - x: The horizontal origin of the crop region (0-indexed from left).
    ///   - y: The vertical origin of the crop region (0-indexed from top).
    ///   - width: The width of the crop region.
    ///   - height: The height of the crop region.
    /// - Returns: A new ``PixelImage`` containing only the cropped pixels.
    /// - Throws: ``PixelPeeperError/invalidCropRegion(x:y:width:height:imageWidth:imageHeight:)``
    ///   if the resulting crop area is zero.
    func cropped(x: Int, y: Int, width cropWidth: Int, height cropHeight: Int) throws -> PixelImage {
        // Clip to image bounds
        let clippedX = max(x, 0)
        let clippedY = max(y, 0)
        let clippedRight = min(x + cropWidth, width)
        let clippedBottom = min(y + cropHeight, height)
        let clippedWidth = clippedRight - clippedX
        let clippedHeight = clippedBottom - clippedY

        guard clippedWidth > 0, clippedHeight > 0 else {
            throw PixelPeeperError.invalidCropRegion(
                x: x, y: y, width: cropWidth, height: cropHeight,
                imageWidth: width, imageHeight: height,
            )
        }

        var croppedPixels = [UInt8]()
        croppedPixels.reserveCapacity(clippedWidth * clippedHeight * 4)

        for row in clippedY ..< clippedBottom {
            let rowStart = (row * width + clippedX) * 4
            let rowEnd = rowStart + clippedWidth * 4
            croppedPixels.append(contentsOf: pixels[rowStart ..< rowEnd])
        }

        return PixelImage(width: clippedWidth, height: clippedHeight, pixels: croppedPixels)
    }
}
