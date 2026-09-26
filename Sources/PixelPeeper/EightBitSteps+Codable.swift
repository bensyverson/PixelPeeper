public extension EightBitSteps {
    /// Decodes a figure from a bare number of steps.
    ///
    /// - Parameter decoder: The decoder to read from.
    /// - Throws: A `DecodingError` when the value is not a number.
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        try self.init(container.decode(Double.self))
    }

    /// Encodes the figure as a bare number of steps, so JSON reads `"maeSteps": 1.25`.
    ///
    /// - Parameter encoder: The encoder to write to.
    /// - Throws: An `EncodingError` when the value cannot be encoded.
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}
