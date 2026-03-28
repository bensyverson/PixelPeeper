import Foundation
import PixelPeeper

extension PeepCommand {
    /// Formats a comparison result as a human-readable text summary.
    ///
    /// - Parameter result: The comparison result to format.
    /// - Returns: A multi-line string with overall and per-channel MAE values.
    static func formatText(_ result: ImageComparisonResult) -> String {
        let mae = formatValue(result.mae)
        let r = formatValue(result.red)
        let g = formatValue(result.green)
        let b = formatValue(result.blue)
        let a = formatValue(result.alpha)

        return """
        MAE: \(mae)
          R: \(r)
          G: \(g)
          B: \(b)
          A: \(a)
        """
    }

    /// Formats a comparison result as a JSON string.
    ///
    /// - Parameter result: The comparison result to format.
    /// - Returns: A JSON string containing all MAE values.
    /// - Throws: An error if encoding fails.
    static func formatJSON(_ result: ImageComparisonResult) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(result)
        return String(data: data, encoding: .utf8)!
    }

    /// Formats a Double value to one decimal place, removing trailing zeros.
    private static func formatValue(_ value: Double) -> String {
        return String(format: "%.1f", value)
    }
}
