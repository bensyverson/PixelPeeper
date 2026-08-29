import CoreGraphics
import Foundation

/// Rasterizing the labelled grid: the in-image lines, the ruler marks and
/// the numbers.
///
/// Split from ``PixelImage/withGrid(_:pixelsPerPoint:origin:)`` so the entry
/// point reads as the contract it is, and from ``GridLayout`` so the geometry
/// can be asserted without wading through drawing state.
extension OverlayCanvas {
    /// Faint lines across the image area at every step, so an element in the
    /// middle can be triangulated between two rulers.
    func drawGridLines(_ layout: GridLayout) {
        for tick in layout.columns {
            fill(
                CGRect(
                    x: Double(layout.leftGutter) + tick.pixelOffset.rounded(.down),
                    y: Double(layout.topGutter),
                    width: 1, height: Double(layout.imageHeight),
                ),
                with: OverlayStyle.line,
            )
        }
        for tick in layout.rows {
            fill(
                CGRect(
                    x: Double(layout.leftGutter),
                    y: Double(layout.topGutter) + tick.pixelOffset.rounded(.down),
                    width: Double(layout.imageWidth), height: 1,
                ),
                with: OverlayStyle.line,
            )
        }
    }

    /// Tick marks and numbers, entirely within the gutters.
    ///
    /// Labels are clipped to their gutter and suppressed when they would run
    /// into the previous one, so a small step never produces a smear of digits.
    func drawRulers(_ layout: GridLayout) {
        let tickLength = Double(OverlayStyle.tickLength)
        let gutterLeft = Double(layout.leftGutter)
        let gutterTop = Double(layout.topGutter)

        for mark in layout.columns {
            fill(
                CGRect(
                    x: gutterLeft + mark.pixelOffset.rounded(.down),
                    y: gutterTop - tickLength,
                    width: 1, height: tickLength,
                ),
                with: OverlayStyle.tick,
            )
        }
        for mark in layout.rows {
            fill(
                CGRect(
                    x: gutterLeft - tickLength,
                    y: gutterTop + mark.pixelOffset.rounded(.down),
                    width: tickLength, height: 1,
                ),
                with: OverlayStyle.tick,
            )
        }

        clipped(to: CGRect(x: gutterLeft, y: 0, width: Double(layout.imageWidth), height: gutterTop)) {
            var nextFreeX = -Double.greatestFiniteMagnitude
            for mark in layout.columns {
                let x = gutterLeft + mark.pixelOffset.rounded(.down) + 2
                guard x >= nextFreeX else { continue }
                draw(
                    mark.label,
                    baselineAt: CGPoint(x: x, y: gutterTop - tickLength - Double(OverlayStyle.labelGap)),
                    color: OverlayStyle.ink,
                )
                nextFreeX = x + OverlayText.width(mark.label) + 6
            }
        }

        clipped(to: CGRect(x: 0, y: 0, width: gutterLeft, height: Double(height))) {
            var nextFreeY = -Double.greatestFiniteMagnitude
            for mark in layout.rows {
                let y = gutterTop + mark.pixelOffset.rounded(.down) + 3
                guard y >= nextFreeY else { continue }
                draw(
                    mark.label,
                    baselineAt: CGPoint(x: Double(OverlayStyle.labelInset), y: y),
                    color: OverlayStyle.ink,
                )
                nextFreeY = y + OverlayStyle.lineHeight
            }
        }
    }
}
