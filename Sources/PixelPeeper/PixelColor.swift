import Foundation

/// The color of a single pixel, expressed as sRGB RGBA components (0–255).
public struct PixelColor: Friendly {
    /// The red channel value (0–255).
    public let red: UInt8

    /// The green channel value (0–255).
    public let green: UInt8

    /// The blue channel value (0–255).
    public let blue: UInt8

    /// The alpha channel value (0–255).
    public let alpha: UInt8

    /// Creates a pixel color with the given RGBA values.
    ///
    /// - Parameters:
    ///   - red: The red channel value (0–255).
    ///   - green: The green channel value (0–255).
    ///   - blue: The blue channel value (0–255).
    ///   - alpha: The alpha channel value (0–255).
    public init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    /// The color as an 8-character hex string with `#` prefix (RRGGBBAA).
    ///
    /// For example, `PixelColor(red: 128, green: 64, blue: 32, alpha: 255).hex`
    /// returns `"#804020ff"`.
    public var hex: String {
        String(format: "#%02x%02x%02x%02x", red, green, blue, alpha)
    }
}
