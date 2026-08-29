import CoreGraphics
import Foundation

public extension PixelImage {
    /// Returns the image surrounded by labelled rulers, numbered in the
    /// caller's own coordinates.
    ///
    /// A vision model reads landmarks; it does not count pixels. Without
    /// numbers burned into the image, an agent looking at a screenshot has to
    /// estimate "about a third of the way down" and turn that into a rectangle,
    /// and an off-by-one at 100 units is a wrong rectangle. So the coordinates
    /// are drawn on: a gutter along the top and left edges carrying tick marks
    /// and numbers every `options.step` source units, plus — in
    /// ``GridOptions/Mode/rulersAndLines`` — a faint line across the image at
    /// every step, so an element in the middle can be triangulated between two
    /// rulers.
    ///
    /// **The numbers are source units.** `pixelsPerPoint` is the ratio between
    /// image pixels and the caller's coordinates, and every label is
    /// `origin` plus the pixel offset divided by it. A 400 pt layout rendered
    /// 800 px wide passes 2 and its ruler reads 0, 100, 200, 300 — not 0, 200,
    /// 400, 600. Pass the ratio you actually ended up at, not the one you asked
    /// for: a scale-2 render later fitted down to fit a size cap is no longer
    /// at 2.
    ///
    /// **Draw the grid last.** The gutter is chrome, not content: fit the image
    /// to whatever size cap you have first, then grid it, or the numbers get
    /// scaled down to illegibility. The cost is that a gridded image exceeds
    /// the cap by its own gutter, which is worth saying out loud in a CLI's
    /// help text.
    ///
    /// In ``GridOptions/Mode/rulers`` the image area is byte-identical to the
    /// input — the pixels are copied at an integer offset, every mark lands in
    /// the gutter, and label text is clipped to the gutter so no antialiased
    /// edge bleeds into the image.
    ///
    /// This is the labelled grid. ``withGridOverlay(spacing:color:)`` is a
    /// different, unlabelled thing that draws in pixel space.
    ///
    /// - Parameters:
    ///   - options: the mode and step. Defaults to lines at every 100 units.
    ///   - pixelsPerPoint: image pixels per source unit; must be positive.
    ///   - origin: the source coordinate of the image's top-left pixel — a
    ///     crop's offset, added to every label. Defaults to `.zero`.
    /// - Returns: a new image, larger than the input by its gutters.
    /// - Throws: ``PixelPeeperError/invalidOverlayScale(_:)`` for a
    ///   non-positive scale, ``PixelPeeperError/invalidGridStep(_:)`` for a
    ///   non-positive step, or
    ///   ``PixelPeeperError/overlayRenderFailed(width:height:)`` if the bitmap
    ///   cannot be built.
    func withGrid(
        _ options: GridOptions = GridOptions(),
        pixelsPerPoint: Double,
        origin: CGPoint = .zero,
    ) throws -> PixelImage {
        guard pixelsPerPoint > 0 else {
            throw PixelPeeperError.invalidOverlayScale(pixelsPerPoint)
        }
        guard options.step > 0 else {
            throw PixelPeeperError.invalidGridStep(options.step)
        }
        let layout = GridLayout(
            imageWidth: width, imageHeight: height,
            options: options, pixelsPerPoint: pixelsPerPoint, origin: origin,
        )
        let canvas = try OverlayCanvas(width: layout.width, height: layout.height)

        canvas.fill(
            CGRect(x: 0, y: 0, width: layout.width, height: layout.height),
            with: OverlayStyle.gutter,
        )
        canvas.blit(self, atX: layout.leftGutter, y: layout.topGutter)
        if options.mode == .rulersAndLines { canvas.drawGridLines(layout) }
        canvas.drawRulers(layout)

        return try canvas.snapshot()
    }
}
