import Foundation

public extension PixelColor {
    /// Creates a pixel color from a hex string.
    ///
    /// Accepts `#RRGGBB` (alpha defaults to 255) and `#RRGGBBAA` formats.
    /// Parsing is case-insensitive.
    ///
    /// - Parameter hex: A hex color string with `#` prefix.
    /// - Throws: ``PixelPeeperError/invalidHexColor(_:)`` if the string is not a valid hex color.
    init(hex: String) throws {
        guard hex.hasPrefix("#") else {
            throw PixelPeeperError.invalidHexColor(hex)
        }

        let digits = String(hex.dropFirst())

        guard digits.count == 6 || digits.count == 8 else {
            throw PixelPeeperError.invalidHexColor(hex)
        }

        guard let value = UInt64(digits, radix: 16) else {
            throw PixelPeeperError.invalidHexColor(hex)
        }

        if digits.count == 6 {
            self.init(
                red: UInt8((value >> 16) & 0xFF),
                green: UInt8((value >> 8) & 0xFF),
                blue: UInt8(value & 0xFF),
                alpha: 255,
            )
        } else {
            self.init(
                red: UInt8((value >> 24) & 0xFF),
                green: UInt8((value >> 16) & 0xFF),
                blue: UInt8((value >> 8) & 0xFF),
                alpha: UInt8(value & 0xFF),
            )
        }
    }
}
