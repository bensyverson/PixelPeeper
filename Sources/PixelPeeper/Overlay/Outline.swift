import CoreGraphics
import Foundation

/// A box to draw around a region of an image, given in the caller's own
/// coordinates.
///
/// See ``PixelImage/withOutlines(_:pixelsPerPoint:origin:)`` for how one is
/// drawn. The important property is that the ring sits *outside* ``rect``: an
/// outline never covers the edge pixels of the thing it is pointing at, so the
/// same image can be measured and annotated at once.
public struct Outline: Friendly {
    /// The region to box, in source units — layout points, CSS px, whatever
    /// the caller's coordinates are.
    public let rect: CGRect

    /// The ring's colour, or `nil` for the default two-tone ring, which reads
    /// on a light background and a dark one alike.
    public let color: PixelColor?

    /// An optional name, drawn in a filled tag at the rect's top-left.
    public let label: String?

    /// The ring's thickness in *image pixels* — not source units, because a
    /// hairline is a hairline whatever the render scale.
    public let width: Double

    /// Creates an outline.
    ///
    /// - Parameters:
    ///   - rect: the region to box, in source units.
    ///   - color: the ring's colour, or `nil` for the default two-tone ring.
    ///   - label: an optional name for the tag.
    ///   - width: the ring's thickness in image pixels. Defaults to 2.
    public init(rect: CGRect, color: PixelColor? = nil, label: String? = nil, width: Double = 2) {
        self.rect = rect
        self.color = color
        self.label = label
        self.width = width
    }

    /// Where the rect lands in image pixels.
    ///
    /// Edges are rounded to whole pixels so the ring drawn around them is
    /// crisp, and so a caller can predict exactly which pixels the box covers.
    ///
    /// - Parameters:
    ///   - pixelsPerPoint: image pixels per source unit.
    ///   - origin: the source coordinate of the image's top-left pixel — a
    ///     crop's offset, subtracted from the rect. Defaults to `.zero`.
    /// - Returns: the rect in image pixels, with integral edges.
    public func pixelRect(pixelsPerPoint: Double, origin: CGPoint = .zero) -> CGRect {
        let left = (Double(rect.minX) - Double(origin.x)) * pixelsPerPoint
        let top = (Double(rect.minY) - Double(origin.y)) * pixelsPerPoint
        let right = (Double(rect.maxX) - Double(origin.x)) * pixelsPerPoint
        let bottom = (Double(rect.maxY) - Double(origin.y)) * pixelsPerPoint
        return CGRect(
            x: left.rounded(), y: top.rounded(),
            width: right.rounded() - left.rounded(),
            height: bottom.rounded() - top.rounded(),
        )
    }
}
