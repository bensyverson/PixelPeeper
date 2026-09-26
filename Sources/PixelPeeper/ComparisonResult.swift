/// The result of comparing two images using Mean Absolute Error (MAE).
///
/// ``mae``, ``red``, ``green``, ``blue`` and ``alpha`` are on a 0–100 scale, where 0 means
/// identical and 100 means maximally different. ``mae`` is the overall average across all
/// four channels; the others are per-channel breakdowns.
///
/// ``maeSteps`` is the same overall figure in 8-bit channel steps (0–255) — the scale the
/// pixel bytes themselves use, and the one to pin a regression threshold in. Its unit is
/// carried by ``EightBitSteps``, so it cannot be compared against a 0–100 figure by accident.
public struct ImageComparisonResult: Friendly {
    /// The overall Mean Absolute Error across all channels (0–100).
    public let mae: Double

    /// The overall Mean Absolute Error across all channels, in 8-bit channel steps (0–255).
    public let maeSteps: EightBitSteps

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
    ///   - maeSteps: Overall MAE across all channels, in 8-bit channel steps (0–255).
    ///   - red: Red channel MAE (0–100).
    ///   - green: Green channel MAE (0–100).
    ///   - blue: Blue channel MAE (0–100).
    ///   - alpha: Alpha channel MAE (0–100).
    public init(mae: Double, maeSteps: EightBitSteps, red: Double, green: Double, blue: Double, alpha: Double) {
        self.mae = mae
        self.maeSteps = maeSteps
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
}
