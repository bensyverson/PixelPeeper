/// A mean absolute error measured in 8-bit channel steps.
///
/// One step is one unit of an 8-bit channel byte, so the scale runs from 0 (identical)
/// to 255 (every channel of every pixel at the opposite extreme). The unit lives in the
/// type so a figure on this scale cannot be mistaken for, or compared against, one on
/// the 0–100 scale of ``ImageComparisonResult/mae``.
///
/// A literal reads as steps, so a threshold is written the way it is read:
///
/// ```swift
/// #expect(result.maeSteps < 2.55)
/// ```
public struct EightBitSteps: Friendly, Comparable, ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral,
    CustomStringConvertible
{
    /// The error, in 8-bit channel steps (0–255).
    public let value: Double

    /// Creates a figure of the given number of steps.
    ///
    /// - Parameter value: The error, in 8-bit channel steps (0–255).
    public init(_ value: Double) {
        self.value = value
    }

    /// Creates a figure from a floating-point literal, in steps.
    ///
    /// - Parameter value: The error, in 8-bit channel steps.
    public init(floatLiteral value: Double) {
        self.value = value
    }

    /// Creates a figure from an integer literal, in steps.
    ///
    /// - Parameter value: The error, in 8-bit channel steps.
    public init(integerLiteral value: Int) {
        self.value = Double(value)
    }

    /// The value followed by its unit, for example `1.25 steps`.
    public var description: String {
        "\(value) steps"
    }

    /// Orders two figures by their value.
    public static func < (lhs: EightBitSteps, rhs: EightBitSteps) -> Bool {
        lhs.value < rhs.value
    }
}
