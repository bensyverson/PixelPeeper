import CoreGraphics
import CoreText
import Foundation

/// The overlay's type: one font, one way to measure it, one way to lay a line.
///
/// Every label an overlay draws — ruler numbers, outline tags — goes through
/// here, so a gutter sized by ``width(_:size:)`` is exactly wide enough for
/// what ``line(_:size:color:)`` will actually draw.
///
/// **Why a fixed monospaced face.** Digits in a monospaced font share an
/// advance, so a ruler's columns line up and a label's width is arithmetic
/// rather than a measurement that changes with the string. Menlo is asked for
/// by name — it ships on both macOS and iOS — so the same code produces the
/// same pixels on both, falling back to the platform's own fixed-pitch UI font
/// only if it is missing.
enum OverlayText {
    /// The overlay's typeface at a given size.
    ///
    /// - Parameter size: the point size; defaults to ``OverlayStyle/fontSize``.
    /// - Returns: Menlo where it is installed, else the platform's fixed-pitch
    ///   UI font, else Courier.
    static func font(ofSize size: Double = OverlayStyle.fontSize) -> CTFont {
        let menlo: CTFont = CTFontCreateWithName("Menlo-Regular" as CFString, size, nil)
        if (CTFontCopyPostScriptName(menlo) as String) == "Menlo-Regular" { return menlo }
        if let fixed: CTFont = CTFontCreateUIFontForLanguage(.userFixedPitch, size, nil) { return fixed }
        return CTFontCreateWithName("Courier" as CFString, size, nil)
    }

    /// How wide a string prints, in pixels.
    ///
    /// This is what sizes a grid's left gutter and an outline's label tag.
    ///
    /// - Parameters:
    ///   - text: the string to measure.
    ///   - size: the point size; defaults to ``OverlayStyle/fontSize``.
    /// - Returns: the typographic advance width in pixels.
    static func width(_ text: String, size: Double = OverlayStyle.fontSize) -> Double {
        let line: CTLine = CTLineCreateWithAttributedString(
            attributed(text, size: size, color: OverlayStyle.ink),
        )
        return CTLineGetTypographicBounds(line, nil, nil, nil)
    }

    /// A laid-out line ready for `CTLineDraw`.
    ///
    /// - Parameters:
    ///   - text: the string to set.
    ///   - size: the point size.
    ///   - color: the ink.
    /// - Returns: a `CTLine` whose origin is its baseline's left end.
    static func line(_ text: String, size: Double = OverlayStyle.fontSize, color: PixelColor) -> CTLine {
        CTLineCreateWithAttributedString(attributed(text, size: size, color: color))
    }

    /// The attributed string Core Text wants.
    private static func attributed(_ text: String, size: Double, color: PixelColor) -> NSAttributedString {
        NSAttributedString(string: text, attributes: [
            NSAttributedString.Key(kCTFontAttributeName as String): font(ofSize: size),
            NSAttributedString.Key(kCTForegroundColorAttributeName as String): color.cgColor,
        ])
    }
}
