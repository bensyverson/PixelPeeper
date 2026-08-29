import CoreGraphics
import CoreText
import Foundation

/// A bitmap the overlays draw into, addressed the way a reader addresses an
/// image: origin top-left, y growing downward.
///
/// Core Graphics puts its origin at the bottom-left, which is the wrong way up
/// for everything an overlay does — a rect handed in by a layout engine, a
/// crop origin, a pixel a test wants to assert on. Rather than flip the CTM
/// (which would also flip the glyphs), every primitive here takes a top-left
/// rectangle and converts on the way in, so no caller ever has to think about
/// it.
///
/// The canvas is deliberately hard-edged: antialiasing and interpolation are
/// off for shapes, and the source image is copied byte for byte rather than
/// drawn, so an overlay never resamples the pixels it is annotating.
struct OverlayCanvas {
    /// The bitmap's width in pixels.
    let width: Int

    /// The bitmap's height in pixels.
    let height: Int

    /// The Core Graphics context backing the bitmap.
    let context: CGContext

    /// Creates a blank canvas of the given pixel size.
    ///
    /// - Parameters:
    ///   - width: the bitmap's width in pixels; must be positive.
    ///   - height: the bitmap's height in pixels; must be positive.
    /// - Throws: ``PixelPeeperError/overlayRenderFailed(width:height:)`` if the
    ///   size is degenerate or the bitmap cannot be allocated.
    init(width: Int, height: Int) throws {
        guard width > 0, height > 0 else {
            throw PixelPeeperError.overlayRenderFailed(width: width, height: height)
        }
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
            | CGBitmapInfo.byteOrder32Big.rawValue
        guard let context = CGContext(
            data: nil, width: width, height: height,
            bitsPerComponent: 8, bytesPerRow: width * 4,
            space: colorSpace, bitmapInfo: bitmapInfo,
        ) else {
            throw PixelPeeperError.overlayRenderFailed(width: width, height: height)
        }
        self.width = width
        self.height = height
        self.context = context
        context.setShouldAntialias(false)
        context.interpolationQuality = .none
    }

    // MARK: - Shapes

    /// Fills a rectangle given in top-left coordinates.
    ///
    /// - Parameters:
    ///   - rect: the rectangle, y measured downward from the top edge.
    ///   - color: the paint.
    func fill(_ rect: CGRect, with color: PixelColor) {
        guard rect.width > 0, rect.height > 0 else { return }
        context.setFillColor(color.cgColor)
        context.fill(flipped(rect))
    }

    /// Runs `body` with drawing clipped to a top-left rectangle.
    ///
    /// - Parameters:
    ///   - rect: the clip region, y measured downward from the top edge.
    ///   - body: the drawing to confine to it.
    func clipped(to rect: CGRect, _ body: () -> Void) {
        context.saveGState()
        context.clip(to: flipped(rect))
        body()
        context.restoreGState()
    }

    // MARK: - Images

    /// Copies an image's pixels in at an integer top-left offset.
    ///
    /// A byte copy rather than a `CGContext.draw`, so the annotated pixels are
    /// exactly the pixels handed in — no resampling, no colour conversion, no
    /// compositing against whatever the canvas already held. Rows and columns
    /// that fall outside the canvas are dropped.
    ///
    /// - Parameters:
    ///   - image: the pixels to copy.
    ///   - x: the destination's left edge, in canvas pixels.
    ///   - y: the destination's top edge, in canvas pixels.
    func blit(_ image: PixelImage, atX x: Int, y: Int) {
        guard let base = context.data else { return }
        let bytesPerRow = context.bytesPerRow
        let firstRow = max(0, -y)
        let lastRow = min(image.height, height - y)
        let firstColumn = max(0, -x)
        let lastColumn = min(image.width, width - x)
        guard firstRow < lastRow, firstColumn < lastColumn else { return }
        let runBytes = (lastColumn - firstColumn) * 4
        let destination = base.assumingMemoryBound(to: UInt8.self)

        image.pixels.withUnsafeBufferPointer { source in
            guard let sourceBase = source.baseAddress else { return }
            for row in firstRow ..< lastRow {
                let sourceOffset = (row * image.width + firstColumn) * 4
                let destinationOffset = (y + row) * bytesPerRow + (x + firstColumn) * 4
                (destination + destinationOffset).update(from: sourceBase + sourceOffset, count: runBytes)
            }
        }
    }

    // MARK: - Text

    /// Draws one line of text with its baseline's left end at a top-left point.
    ///
    /// Font smoothing and subpixel positioning are switched off so the same
    /// string at the same place produces the same bytes on every run.
    ///
    /// - Parameters:
    ///   - text: the string to draw.
    ///   - point: the baseline's left end, y measured downward from the top.
    ///   - size: the point size.
    ///   - color: the ink.
    func draw(_ text: String, baselineAt point: CGPoint, size: Double = OverlayStyle.fontSize, color: PixelColor) {
        context.saveGState()
        context.setShouldAntialias(true)
        context.setShouldSmoothFonts(false)
        context.setShouldSubpixelPositionFonts(false)
        context.setShouldSubpixelQuantizeFonts(false)
        context.textMatrix = CGAffineTransform.identity
        context.textPosition = CGPoint(x: point.x, y: Double(height) - point.y)
        CTLineDraw(OverlayText.line(text, size: size, color: color), context)
        context.restoreGState()
    }

    /// Draws a filled tag with its text, clamped to stay inside the canvas.
    ///
    /// The tag is the overlay's one way of putting a word on an image: a solid
    /// block behind the text, so it reads over whatever it lands on.
    ///
    /// - Parameters:
    ///   - text: the label.
    ///   - point: the tag's preferred top-left corner, in canvas pixels.
    ///   - background: the tag's fill; the text takes whichever of black or
    ///     white reads on it.
    /// - Returns: the rectangle the tag actually occupies, after clamping.
    @discardableResult
    func drawTag(_ text: String, topLeft point: CGPoint, background: PixelColor) -> CGRect {
        let tagWidth = Int(OverlayText.width(text).rounded(.up)) + OverlayStyle.tagPaddingX * 2
        let tagHeight = OverlayStyle.tagHeight
        let x = min(max(0, Int(point.x.rounded())), max(0, width - tagWidth))
        let y = min(max(0, Int(point.y.rounded())), max(0, height - tagHeight))
        let rect = CGRect(x: x, y: y, width: tagWidth, height: tagHeight)

        fill(rect, with: background)
        clipped(to: rect) {
            draw(
                text,
                baselineAt: CGPoint(x: x + OverlayStyle.tagPaddingX, y: y + OverlayStyle.tagBaseline),
                color: OverlayStyle.textColor(on: background),
            )
        }
        return rect
    }

    // MARK: - Reading back

    /// Copies the bitmap out as a ``PixelImage``.
    ///
    /// - Returns: the canvas's pixels, row-major RGBA, top row first.
    /// - Throws: ``PixelPeeperError/overlayRenderFailed(width:height:)`` if the
    ///   bitmap's memory cannot be read.
    func snapshot() throws -> PixelImage {
        guard let base = context.data else {
            throw PixelPeeperError.overlayRenderFailed(width: width, height: height)
        }
        let bytesPerRow = context.bytesPerRow
        let rowBytes = width * 4
        let source = base.assumingMemoryBound(to: UInt8.self)
        var pixels = [UInt8](repeating: 0, count: width * height * 4)

        pixels.withUnsafeMutableBufferPointer { destination in
            guard let destinationBase = destination.baseAddress else { return }
            for row in 0 ..< height {
                (destinationBase + row * rowBytes)
                    .update(from: source + row * bytesPerRow, count: rowBytes)
            }
        }
        return PixelImage(width: width, height: height, pixels: pixels)
    }

    // MARK: - Coordinates

    /// Turns a top-left rectangle into the Core Graphics one that covers the
    /// same pixels.
    private func flipped(_ rect: CGRect) -> CGRect {
        CGRect(x: rect.minX, y: Double(height) - rect.maxY, width: rect.width, height: rect.height)
    }
}
