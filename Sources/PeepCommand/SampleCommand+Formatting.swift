import Foundation
import PixelPeeper

extension SampleCommand {
    /// Formats a pixel color as a hex string (RRGGBBAA).
    ///
    /// - Parameter color: The pixel color to format.
    /// - Returns: An 8-character hex string with `#` prefix.
    static func formatHex(_ color: PixelColor) -> String {
        color.hex
    }

    /// Formats a pixel color as a human-readable text summary.
    ///
    /// - Parameter color: The pixel color to format.
    /// - Returns: A multi-line string with labeled RGBA values.
    static func formatText(_ color: PixelColor) -> String {
        """
        R: \(color.red)
        G: \(color.green)
        B: \(color.blue)
        A: \(color.alpha)
        """
    }

    /// Formats a pixel color as a JSON string.
    ///
    /// - Parameter color: The pixel color to format.
    /// - Returns: A JSON string containing RGBA integer values.
    /// - Throws: An error if encoding fails.
    static func formatJSON(_ color: PixelColor) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(color)
        return String(data: data, encoding: .utf8)!
    }
}
