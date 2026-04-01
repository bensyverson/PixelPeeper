import Foundation
import PixelPeeper

extension LineSampleCommand {
    /// Formats line samples as human-readable text.
    ///
    /// Each line shows coordinates followed by the hex color:
    /// ```
    /// 89, 241: #rrggbbaa
    /// ```
    ///
    /// - Parameter samples: The line samples to format.
    /// - Returns: A multi-line text string.
    static func formatText(_ samples: [LineSample]) -> String {
        samples.map { sample in
            "\(sample.x), \(sample.y): \(sample.color.hex)"
        }.joined(separator: "\n")
    }

    /// Formats line samples as a JSON array.
    ///
    /// - Parameter samples: The line samples to format.
    /// - Returns: A JSON string in the format `[{"x": 0, "y": 0, "color": "#rrggbbaa"}, ...]`.
    /// - Throws: An error if encoding fails.
    static func formatJSON(_ samples: [LineSample]) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(samples)
        return String(data: data, encoding: .utf8)!
    }
}
