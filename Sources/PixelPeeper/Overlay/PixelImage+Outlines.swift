import CoreGraphics
import Foundation

public extension PixelImage {
    /// Returns the image with a box drawn around each of the given regions,
    /// named in the caller's own coordinates.
    ///
    /// This is what turns "the header is somewhere up there" into "the header
    /// is *here*": hand in the rectangle your layout engine computed, in the
    /// units it computed it in, and get back a picture of where that rectangle
    /// actually landed.
    ///
    /// **The ring is outside the rect.** Every pixel of the box sits beyond
    /// ``Outline/rect``'s edges, so the outline never covers the edge pixels of
    /// the thing it points at — the same image can be read for "did the border
    /// render?" and "where is it?" at once.
    ///
    /// **The default colour is two-tone.** With no ``Outline/color`` the ring
    /// is drawn half in near-black next to the rect and half in white outside
    /// it, so it is visible on a white page and a dark one alike, with no
    /// caller having to know which they have. A named colour is drawn solid at
    /// the full width.
    ///
    /// A ``Outline/label`` is drawn in a filled tag just above the rect's
    /// top-left, dropped inside the rect when there is no room above and
    /// clamped to stay within the image.
    ///
    /// - Parameters:
    ///   - outlines: the regions to box. An empty list returns the image
    ///     unchanged.
    ///   - pixelsPerPoint: image pixels per source unit; must be positive.
    ///   - origin: the source coordinate of the image's top-left pixel — a
    ///     crop's offset, subtracted from every rect. Defaults to `.zero`.
    /// - Returns: a new image the same size as the input.
    /// - Throws: ``PixelPeeperError/invalidOverlayScale(_:)`` for a
    ///   non-positive scale, or
    ///   ``PixelPeeperError/overlayRenderFailed(width:height:)`` if the bitmap
    ///   cannot be built.
    func withOutlines(
        _ outlines: [Outline],
        pixelsPerPoint: Double,
        origin: CGPoint = .zero,
    ) throws -> PixelImage {
        guard pixelsPerPoint > 0 else {
            throw PixelPeeperError.invalidOverlayScale(pixelsPerPoint)
        }
        guard !outlines.isEmpty else { return self }

        let canvas = try OverlayCanvas(width: width, height: height)
        canvas.blit(self, atX: 0, y: 0)
        for outline in outlines {
            canvas.draw(outline, pixelsPerPoint: pixelsPerPoint, origin: origin)
        }
        return try canvas.snapshot()
    }
}
