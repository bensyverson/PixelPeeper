import CoreGraphics
import Foundation

/// A word to burn onto an image at a point in the caller's own coordinates.
///
/// The same filled tag an ``Outline`` uses for its name, but free-standing:
/// what you reach for to mark a measurement, a click target, or a landmark
/// that is not a rectangle. See
/// ``PixelImage/withLabels(_:pixelsPerPoint:origin:)``.
///
/// Named `OverlayLabel` rather than `Label` because consumers of this package
/// are SwiftUI apps, where `Label` is already taken.
public struct OverlayLabel: Friendly {
    /// The text to draw.
    public let text: String

    /// The tag's top-left corner, in source units.
    public let position: CGPoint

    /// The tag's fill, or `nil` for the default dark tag. The text takes
    /// whichever of black or white reads on the fill.
    public let color: PixelColor?

    /// Creates a label.
    ///
    /// - Parameters:
    ///   - text: the text to draw.
    ///   - position: the tag's top-left corner, in source units.
    ///   - color: the tag's fill, or `nil` for the default dark tag.
    public init(text: String, position: CGPoint, color: PixelColor? = nil) {
        self.text = text
        self.position = position
        self.color = color
    }

    /// Where the tag's top-left corner lands in image pixels.
    ///
    /// - Parameters:
    ///   - pixelsPerPoint: image pixels per source unit.
    ///   - origin: the source coordinate of the image's top-left pixel.
    ///     Defaults to `.zero`.
    /// - Returns: the position in image pixels, before any clamping.
    public func pixelPosition(pixelsPerPoint: Double, origin: CGPoint = .zero) -> CGPoint {
        CGPoint(
            x: (Double(position.x) - Double(origin.x)) * pixelsPerPoint,
            y: (Double(position.y) - Double(origin.y)) * pixelsPerPoint,
        )
    }
}
