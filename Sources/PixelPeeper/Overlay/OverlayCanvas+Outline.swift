import CoreGraphics
import Foundation

/// Rasterizing one outline: the ring bands and the label's tag.
///
/// The ring is drawn as four filled bands rather than a stroked path. A stroke
/// is centred on its path, so keeping it outside the rect means offsetting the
/// path by half the line width and reasoning about joins; four rectangles are
/// exact at any width, need no antialiasing, and make "outside the rect" a
/// property of the arithmetic rather than of Core Graphics' stroking rules.
extension OverlayCanvas {
    /// Draws one outline.
    ///
    /// - Parameters:
    ///   - outline: the box to draw.
    ///   - pixelsPerPoint: image pixels per source unit.
    ///   - origin: the source coordinate of the image's top-left pixel.
    func draw(_ outline: Outline, pixelsPerPoint: Double, origin: CGPoint) {
        let rect = outline.pixelRect(pixelsPerPoint: pixelsPerPoint, origin: origin)
        let thickness = max(1, Int(outline.width.rounded()))

        if let color = outline.color {
            ring(around: rect, offset: 0, thickness: thickness, color: color)
        } else if thickness >= 2 {
            let inner = thickness / 2
            ring(around: rect, offset: 0, thickness: inner, color: OverlayStyle.outlineDark)
            ring(
                around: rect, offset: inner, thickness: thickness - inner,
                color: OverlayStyle.outlineLight,
            )
        } else {
            ring(around: rect, offset: 0, thickness: thickness, color: OverlayStyle.outlineDark)
        }

        guard let label = outline.label else { return }
        let above = rect.minY - Double(thickness) - Double(OverlayStyle.tagHeight)
        drawTag(
            label,
            topLeft: CGPoint(x: rect.minX - Double(thickness), y: above < 0 ? rect.minY : above),
            background: outline.color ?? OverlayStyle.tagFill,
        )
    }

    /// One band of a ring: a rectangular annulus `thickness` pixels wide,
    /// sitting `offset` pixels beyond `rect`'s edges.
    ///
    /// - Parameters:
    ///   - rect: the region being boxed, in image pixels.
    ///   - offset: how far beyond the rect this band starts.
    ///   - thickness: the band's width in pixels.
    ///   - color: the paint.
    private func ring(around rect: CGRect, offset: Int, thickness: Int, color: PixelColor) {
        guard thickness > 0 else { return }
        let inset = Double(offset)
        let band = Double(thickness)
        let outer = rect.insetBy(dx: -inset, dy: -inset)

        // Left and right run the full height plus both corners; top and bottom
        // fill the span between them, so every corner is painted exactly once.
        fill(CGRect(x: outer.minX - band, y: outer.minY - band, width: band, height: outer.height + band * 2), with: color)
        fill(CGRect(x: outer.maxX, y: outer.minY - band, width: band, height: outer.height + band * 2), with: color)
        fill(CGRect(x: outer.minX, y: outer.minY - band, width: outer.width, height: band), with: color)
        fill(CGRect(x: outer.minX, y: outer.maxY, width: outer.width, height: band), with: color)
    }
}
