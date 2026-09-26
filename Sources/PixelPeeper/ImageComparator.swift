/// Compares two images by computing their Mean Absolute Error (MAE).
///
/// `ImageComparator` provides a static ``compare(_:_:options:)`` method that computes
/// the per-channel and overall MAE between two ``PixelImage`` values on a 0–100 scale,
/// and the overall MAE in 8-bit channel steps (0–255) as ``ImageComparisonResult/maeSteps``.
///
/// ## Example
///
/// ```swift
/// let image1 = try PixelImage.load(from: url1)
/// let image2 = try PixelImage.load(from: url2)
/// let result = try ImageComparator.compare(image1, image2)
/// print("MAE: \(result.maeSteps)") // e.g. "1.25 steps"
/// ```
public enum ImageComparator {
    /// Compares two images and returns their Mean Absolute Error.
    ///
    /// The MAE is computed per channel (red, green, blue, alpha) and then averaged
    /// to produce the overall score. All values are normalized to a 0–100 scale, except
    /// ``ImageComparisonResult/maeSteps``, which is the summed byte difference of every
    /// channel (alpha included) divided by the number of channels compared — the same
    /// overall figure in 8-bit channel steps (0–255), computed in one division.
    ///
    /// The pixels compared are the images' own bytes: sRGB, 8 bits per channel,
    /// premultiplied alpha, as ``PixelImage`` stores them.
    ///
    /// - Parameters:
    ///   - image1: The first image to compare.
    ///   - image2: The second image to compare.
    ///   - options: Comparison options controlling behavior such as dimension mismatch handling.
    ///     Defaults to ``ComparisonOptions/default``.
    /// - Returns: An ``ImageComparisonResult`` containing overall and per-channel MAE values.
    /// - Throws: ``PixelPeeperError/dimensionMismatch(width1:height1:width2:height2:)``
    ///   if images have different dimensions and options are set to error.
    ///   ``PixelPeeperError/invalidCropRegion(x:y:width:height:imageWidth:imageHeight:)``
    ///   if ``ComparisonOptions/DimensionMismatch/cropToOverlap`` leaves no overlap
    ///   (one image is zero pixels wide or tall).
    public static func compare(
        _ image1: PixelImage,
        _ image2: PixelImage,
        options: ComparisonOptions = .default,
    ) throws -> ImageComparisonResult {
        var img1 = image1
        var img2 = image2

        if img1.width != img2.width || img1.height != img2.height {
            switch options.dimensionMismatch {
            case .error:
                throw PixelPeeperError.dimensionMismatch(
                    width1: img1.width, height1: img1.height,
                    width2: img2.width, height2: img2.height,
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
            case .cropToOverlap:
                let targetWidth = min(img1.width, img2.width)
                let targetHeight = min(img1.height, img2.height)

                if img1.width != targetWidth || img1.height != targetHeight {
                    img1 = try img1.cropped(x: 0, y: 0, width: targetWidth, height: targetHeight)
                }
                if img2.width != targetWidth || img2.height != targetHeight {
                    img2 = try img2.cropped(x: 0, y: 0, width: targetWidth, height: targetHeight)
                }
            }
        }

        let pixelCount = img1.pixelCount
        var redDiff: Int64 = 0
        var greenDiff: Int64 = 0
        var blueDiff: Int64 = 0
        var alphaDiff: Int64 = 0

        precondition(
            img1.pixels.count >= pixelCount * 4 && img2.pixels.count >= pixelCount * 4,
            "PixelImage pixel data is shorter than width × height × 4 bytes",
        )
        // Raw pointers rather than `Array` subscripts: a consumer's test build compiles
        // this package unoptimized, where a bounds-checked subscript per channel made
        // the loop a leading cost of a large snapshot suite.
        img1.pixels.withUnsafeBufferPointer { lhsBytes in
            img2.pixels.withUnsafeBufferPointer { rhsBytes in
                guard let lhs = lhsBytes.baseAddress, let rhs = rhsBytes.baseAddress else { return }
                for offset in stride(from: 0, to: pixelCount * 4, by: 4) {
                    redDiff += Int64(abs(Int32(lhs[offset]) - Int32(rhs[offset])))
                    greenDiff += Int64(abs(Int32(lhs[offset + 1]) - Int32(rhs[offset + 1])))
                    blueDiff += Int64(abs(Int32(lhs[offset + 2]) - Int32(rhs[offset + 2])))
                    alphaDiff += Int64(abs(Int32(lhs[offset + 3]) - Int32(rhs[offset + 3])))
                }
            }
        }

        // One division over the whole integer sum, so the 8-bit figure is exactly
        // total / channels and not a rescaled, re-rounded copy of the 0–100 one.
        let steps = Double(redDiff + greenDiff + blueDiff + alphaDiff) / Double(pixelCount * 4)

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
            maeSteps: EightBitSteps(steps),
            red: normalizedRed,
            green: normalizedGreen,
            blue: normalizedBlue,
            alpha: normalizedAlpha,
        )
    }
}
