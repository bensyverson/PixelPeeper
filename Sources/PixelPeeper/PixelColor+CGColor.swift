import CoreGraphics

public extension PixelColor {
    /// The colour as a Core Graphics colour in the sRGB space.
    ///
    /// Components are divided by 255, so `PixelColor(red: 255, …)` becomes
    /// `1.0`. Alpha is carried through unchanged; a ``PixelImage``'s stored
    /// pixels are premultiplied, but a `PixelColor` used as paint is not, so
    /// this is a straight conversion.
    var cgColor: CGColor {
        CGColor(
            srgbRed: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            alpha: Double(alpha) / 255,
        )
    }
}
