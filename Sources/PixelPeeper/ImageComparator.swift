/// Compares two images by computing their Mean Absolute Error (MAE).
///
/// `ImageComparator` provides a static ``compare(_:_:options:)`` method that computes
/// the per-channel and overall MAE between two ``PixelImage`` values on a 0–100 scale.
///
/// ## Example
///
/// ```swift
/// let image1 = try PixelImage.load(from: url1)
/// let image2 = try PixelImage.load(from: url2)
/// let result = try ImageComparator.compare(image1, image2)
/// print("MAE: \(result.mae)")
/// ```
public enum ImageComparator {
    /// Compares two images and returns their Mean Absolute Error.
    ///
    /// The MAE is computed per channel (red, green, blue, alpha) and then averaged
    /// to produce the overall score. All values are normalized to a 0–100 scale.
    ///
    /// - Parameters:
    ///   - image1: The first image to compare.
    ///   - image2: The second image to compare.
    ///   - options: Comparison options controlling behavior such as dimension mismatch handling.
    ///     Defaults to ``ComparisonOptions/default``.
    /// - Returns: An ``ImageComparisonResult`` containing overall and per-channel MAE values.
    /// - Throws: ``PixelPeeperError/dimensionMismatch(width1:height1:width2:height2:)``
    ///   if images have different dimensions and options are set to error.
    public static func compare(
        _ image1: PixelImage,
        _ image2: PixelImage,
        options: ComparisonOptions = .default
    ) throws -> ImageComparisonResult {
        var img1 = image1
        var img2 = image2

        if img1.width != img2.width || img1.height != img2.height {
            switch options.dimensionMismatch {
            case .error:
                throw PixelPeeperError.dimensionMismatch(
                    width1: img1.width, height1: img1.height,
                    width2: img2.width, height2: img2.height
                )
            case .resizeToSmallest:
                let targetWidth = min(img1.width, img2.width)
                let targetHeight = min(img1.height, img2.height)

                if img1.width != targetWidth || img1.height != targetHeight {
                    img1 = try img1.resized(toWidth: targetWidth, height: targetHeight)
                }
                if img2.width != targetWidth || img2.height != targetHeight {
                    img2 = try img2.resized(toWidth: targetWidth, height: targetHeight)
                }
            }
        }

        let pixelCount = img1.pixelCount
        var redDiff: Int64 = 0
        var greenDiff: Int64 = 0
        var blueDiff: Int64 = 0
        var alphaDiff: Int64 = 0

        for i in 0 ..< pixelCount {
            let offset = i * 4
            redDiff += Int64(abs(Int(img1.pixels[offset]) - Int(img2.pixels[offset])))
            greenDiff += Int64(abs(Int(img1.pixels[offset + 1]) - Int(img2.pixels[offset + 1])))
            blueDiff += Int64(abs(Int(img1.pixels[offset + 2]) - Int(img2.pixels[offset + 2])))
            alphaDiff += Int64(abs(Int(img1.pixels[offset + 3]) - Int(img2.pixels[offset + 3])))
        }

        let count = Double(pixelCount)
        let rawRed = Double(redDiff) / count
        let rawGreen = Double(greenDiff) / count
        let rawBlue = Double(blueDiff) / count
        let rawAlpha = Double(alphaDiff) / count

        // Normalize from 0–255 to 0–100
        let normalizedRed = rawRed / 2.55
        let normalizedGreen = rawGreen / 2.55
        let normalizedBlue = rawBlue / 2.55
        let normalizedAlpha = rawAlpha / 2.55
        let overall = (normalizedRed + normalizedGreen + normalizedBlue + normalizedAlpha) / 4.0

        return ImageComparisonResult(
            mae: overall,
            red: normalizedRed,
            green: normalizedGreen,
            blue: normalizedBlue,
            alpha: normalizedAlpha
        )
    }
}
