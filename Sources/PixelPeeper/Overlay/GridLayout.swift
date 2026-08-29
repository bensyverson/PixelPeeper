import CoreGraphics
import Foundation

/// Where every part of a labelled grid goes: the gutter widths and the two
/// rulers' ticks.
///
/// Separated from the drawing so the geometry can be asserted — and a caller
/// can predict the output size, or map a pixel back to a source coordinate —
/// without rasterizing anything.
///
/// **Source coordinates, not image coordinates.** Every label is the `origin`
/// plus the pixel offset divided by `pixelsPerPoint`, so a crop taken at
/// y = 850 prints `900` on its first horizontal ruler, not `50`. That number
/// pastes straight back into whatever asked for the crop.
public struct GridLayout: Friendly {
    /// One ruler mark: where it lands in the image, and what it reads.
    public struct Tick: Friendly {
        /// The source coordinate — what the label says.
        public let position: Int

        /// How far into the image the mark sits, in pixels, measured from the
        /// left edge (for a column) or the top edge (for a row).
        public let pixelOffset: Double

        /// Creates a tick.
        ///
        /// - Parameters:
        ///   - position: the source coordinate.
        ///   - pixelOffset: the offset into the image, in pixels.
        public init(position: Int, pixelOffset: Double) {
            self.position = position
            self.pixelOffset = pixelOffset
        }

        /// The number as the ruler prints it.
        public var label: String {
            String(position)
        }
    }

    /// The left gutter's width in pixels — ``minimumGutter``, widened when the
    /// longest row label would not otherwise clear the tick marks.
    public let leftGutter: Int

    /// The top gutter's height in pixels.
    public let topGutter: Int

    /// The top ruler's ticks, offsets measured from the image's left edge.
    public let columns: [Tick]

    /// The left ruler's ticks, offsets measured from the image's top edge.
    public let rows: [Tick]

    /// The un-gridded image's pixel width.
    public let imageWidth: Int

    /// The un-gridded image's pixel height.
    public let imageHeight: Int

    /// The gridded image's pixel width: the image plus its left gutter.
    public var width: Int {
        imageWidth + leftGutter
    }

    /// The gridded image's pixel height: the image plus its top gutter.
    public var height: Int {
        imageHeight + topGutter
    }

    /// Lays out the grid for an image of the given size at the given scale.
    ///
    /// - Parameters:
    ///   - imageWidth: the image's width in pixels.
    ///   - imageHeight: the image's height in pixels.
    ///   - options: the mode and step.
    ///   - pixelsPerPoint: image pixels per source unit — a Woodcase render at
    ///     `--max 800` from a 400 pt layout is 2, a browser shot at
    ///     `--scale 2` later fitted down may be 0.37. Callers pass whatever
    ///     their own fit stage arrived at, and the labels stay correct.
    ///   - origin: the source coordinate of the image's top-left pixel — a
    ///     crop's offset. Added to every label. Defaults to `.zero`.
    public init(
        imageWidth: Int,
        imageHeight: Int,
        options: GridOptions,
        pixelsPerPoint: Double,
        origin: CGPoint = .zero,
    ) {
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
        topGutter = GridLayout.minimumGutter
        columns = GridLayout.ticks(
            fromOrigin: Double(origin.x),
            acrossPixels: imageWidth,
            pixelsPerPoint: pixelsPerPoint,
            step: options.step,
        )
        rows = GridLayout.ticks(
            fromOrigin: Double(origin.y),
            acrossPixels: imageHeight,
            pixelsPerPoint: pixelsPerPoint,
            step: options.step,
        )
        let widest: Double = rows.map { GridLayout.labelWidth($0.label) }.max() ?? 0
        leftGutter = max(
            GridLayout.minimumGutter,
            Int((widest + Double(GridLayout.labelInset * 2 + GridLayout.tickLength)).rounded(.up)),
        )
    }

    /// The ticks a ruler shows for one axis.
    ///
    /// - Parameters:
    ///   - origin: the axis's source coordinate at pixel 0.
    ///   - pixels: the image's extent along the axis, in pixels.
    ///   - pixelsPerPoint: image pixels per source unit.
    ///   - step: the spacing in source units.
    /// - Returns: every multiple of `step` that falls inside the image, in
    ///   ascending order, each with its pixel offset. Empty for a non-positive
    ///   step, scale or extent.
    public static func ticks(
        fromOrigin origin: Double,
        acrossPixels pixels: Int,
        pixelsPerPoint: Double,
        step: Int,
    ) -> [Tick] {
        guard step > 0, pixelsPerPoint > 0, pixels > 0 else { return [] }
        var position = Int((origin / Double(step)).rounded(.up)) * step
        var ticks: [Tick] = []
        while true {
            let offset = (Double(position) - origin) * pixelsPerPoint
            guard offset < Double(pixels) else { return ticks }
            ticks.append(Tick(position: position, pixelOffset: offset))
            position += step
        }
    }

    /// How wide a ruler label prints, in pixels — what sizes the left gutter.
    ///
    /// - Parameter label: the label to measure.
    /// - Returns: the label's advance width in pixels.
    public static func labelWidth(_ label: String) -> Double {
        OverlayText.width(label)
    }

    /// The gutter's thickness in pixels, and the floor for the left gutter.
    public static var minimumGutter: Int {
        OverlayStyle.minimumGutter
    }

    /// The gap between a ruler label and the gutter's outer edge.
    public static var labelInset: Int {
        OverlayStyle.labelInset
    }

    /// How far a tick mark reaches into the gutter.
    public static var tickLength: Int {
        OverlayStyle.tickLength
    }
}
