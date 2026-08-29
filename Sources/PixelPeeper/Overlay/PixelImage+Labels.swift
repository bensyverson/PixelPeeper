import CoreGraphics
import Foundation

public extension PixelImage {
    /// Returns the image with a filled tag drawn at each of the given points,
    /// positioned in the caller's own coordinates.
    ///
    /// The same tag ``withOutlines(_:pixelsPerPoint:origin:)`` uses for an
    /// outline's name, free-standing: for marking a measurement, a click
    /// target, or a landmark that is not a rectangle. Each tag's top-left
    /// corner goes at its ``OverlayLabel/position``, clamped so the tag stays
    /// inside the image.
    ///
    /// - Parameters:
    ///   - labels: the tags to draw. An empty list returns the image unchanged.
    ///   - pixelsPerPoint: image pixels per source unit; must be positive.
    ///   - origin: the source coordinate of the image's top-left pixel — a
    ///     crop's offset, subtracted from every position. Defaults to `.zero`.
    /// - Returns: a new image the same size as the input.
    /// - Throws: ``PixelPeeperError/invalidOverlayScale(_:)`` for a
    ///   non-positive scale, or
    ///   ``PixelPeeperError/overlayRenderFailed(width:height:)`` if the bitmap
    ///   cannot be built.
    func withLabels(
        _ labels: [OverlayLabel],
        pixelsPerPoint: Double,
        origin: CGPoint = .zero,
    ) throws -> PixelImage {
        guard pixelsPerPoint > 0 else {
            throw PixelPeeperError.invalidOverlayScale(pixelsPerPoint)
        }
        guard !labels.isEmpty else { return self }

        let canvas = try OverlayCanvas(width: width, height: height)
        canvas.blit(self, atX: 0, y: 0)
        for label in labels {
            canvas.drawTag(
                label.text,
                topLeft: label.pixelPosition(pixelsPerPoint: pixelsPerPoint, origin: origin),
                background: label.color ?? OverlayStyle.tagFill,
            )
        }
        return try canvas.snapshot()
    }
}
