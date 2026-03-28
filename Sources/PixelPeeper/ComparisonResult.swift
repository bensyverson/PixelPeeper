/// The result of comparing two images using Mean Absolute Error (MAE).
///
/// All values are on a 0–100 scale, where 0 means identical and 100 means maximally different.
/// The ``mae`` property is the overall average across all four channels, while
/// ``red``, ``green``, ``blue``, and ``alpha`` provide per-channel breakdowns.
public struct ImageComparisonResult: Friendly {
    /// The overall Mean Absolute Error across all channels (0–100).
    public let mae: Double

    /// The Mean Absolute Error for the red channel (0–100).
    public let red: Double

    /// The Mean Absolute Error for the green channel (0–100).
    public let green: Double

    /// The Mean Absolute Error for the blue channel (0–100).
    public let blue: Double

    /// The Mean Absolute Error for the alpha channel (0–100).
    public let alpha: Double

    /// Creates a new comparison result with the given MAE values.
    ///
    /// - Parameters:
    ///   - mae: Overall MAE across all channels (0–100).
    ///   - red: Red channel MAE (0–100).
    ///   - green: Green channel MAE (0–100).
    ///   - blue: Blue channel MAE (0–100).
    ///   - alpha: Alpha channel MAE (0–100).
    public init(mae: Double, red: Double, green: Double, blue: Double, alpha: Double) {
        self.mae = mae
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
}
