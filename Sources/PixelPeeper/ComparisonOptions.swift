/// Configuration options for image comparison.
///
/// Use ``ComparisonOptions/default`` for standard behavior that errors on dimension mismatches,
/// or create a custom instance to opt into automatic resizing.
public struct ComparisonOptions: Friendly {
    /// How to handle images with different dimensions.
    public enum DimensionMismatch: String, Friendly {
        /// Throw an error when dimensions don't match.
        case error

        /// Resize the larger image to match the smaller image's dimensions using bilinear interpolation.
        case resizeToSmallest
    }

    /// The strategy for handling images with different dimensions.
    public var dimensionMismatch: DimensionMismatch

    /// Creates comparison options with the given dimension mismatch strategy.
    ///
    /// - Parameter dimensionMismatch: How to handle images with different dimensions.
    public init(dimensionMismatch: DimensionMismatch) {
        self.dimensionMismatch = dimensionMismatch
    }

    /// Default comparison options that error on dimension mismatches.
    public static let `default` = ComparisonOptions(dimensionMismatch: .error)
}
