/// The labelled grid a caller asked for.
///
/// See ``PixelImage/withGrid(_:pixelsPerPoint:origin:)`` for what gets drawn.
public struct GridOptions: Friendly {
    /// How much of the grid to draw.
    public enum Mode: String, Friendly, CaseIterable {
        /// Rulers in the gutter plus a faint line across the image at every
        /// step: the default, and what makes an element in the middle of the
        /// image locatable by triangulating between two rulers.
        case rulersAndLines = "lines"

        /// The gutter only. The image's own pixels come through byte for byte,
        /// which is what a capture being judged for contrast, alignment or a
        /// visual diff needs.
        case rulers
    }

    /// How much to draw.
    public let mode: Mode

    /// The spacing between ruler ticks and lines, in source units.
    public let step: Int

    /// Creates grid options.
    ///
    /// - Parameters:
    ///   - mode: how much to draw. Defaults to ``Mode/rulersAndLines``.
    ///   - step: the spacing between ticks in source units — layout points,
    ///     CSS px, whatever the caller's coordinates are. Defaults to 100.
    public init(mode: Mode = .rulersAndLines, step: Int = 100) {
        self.mode = mode
        self.step = step
    }
}
