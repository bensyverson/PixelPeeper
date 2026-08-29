/// The one place the overlay's colours and metrics are decided.
///
/// Every number an overlay draws with lives here so a ruler, an outline and a
/// label cannot drift apart in ink or spacing, and so a change to the look is
/// a change to one file. The values are deliberately fixed rather than
/// caller-tunable: an overlay is a measuring instrument, and a reader who has
/// learned to read one image's gutter should be able to read every image's.
enum OverlayStyle {
    // MARK: - Text

    /// The point size every overlay label is set at.
    static let fontSize: Double = 9

    /// Baseline-to-baseline spacing, used to suppress overlapping ruler labels.
    static let lineHeight: Double = 12

    // MARK: - Grid metrics

    /// The gutter's thickness in pixels, and the floor for the left gutter.
    static let minimumGutter: Int = 24

    /// The gap between a ruler label and the gutter's outer edge.
    static let labelInset: Int = 3

    /// How far a tick mark reaches into the gutter.
    static let tickLength: Int = 5

    /// The gap between a tick mark and the label that names it.
    static let labelGap: Int = 3

    // MARK: - Tag metrics

    /// The height of a label's filled tag, in pixels.
    static let tagHeight: Int = 14

    /// The horizontal padding inside a tag, in pixels.
    static let tagPaddingX: Int = 3

    /// The text baseline's offset from the tag's top edge, in pixels.
    static let tagBaseline: Int = 10

    // MARK: - Colours

    /// The gutter's fill: near-white, so dark numbers read on it whatever the
    /// image's own theme is.
    static let gutter = PixelColor(red: 247, green: 247, blue: 247, alpha: 255)

    /// The colour ruler labels are set in.
    static let ink = PixelColor(red: 31, green: 31, blue: 36, alpha: 255)

    /// The tick mark colour.
    static let tick = PixelColor(red: 115, green: 115, blue: 122, alpha: 255)

    /// The in-image grid line: a mid-gray at low alpha, legible over a white
    /// page and a dark one alike.
    static let line = PixelColor(red: 128, green: 128, blue: 140, alpha: 89)

    /// The inner half of the default two-tone outline, next to the rect.
    static let outlineDark = PixelColor(red: 17, green: 17, blue: 20, alpha: 255)

    /// The outer half of the default two-tone outline: what carries the box on
    /// a dark background, where the inner half disappears.
    static let outlineLight = PixelColor(red: 255, green: 255, blue: 255, alpha: 255)

    /// The fill behind a label tag when the caller names no colour.
    static let tagFill = PixelColor(red: 17, green: 17, blue: 20, alpha: 255)

    /// Black or white, whichever reads on the given tag fill.
    ///
    /// Uses the Rec. 601 luma of the fill, which is close enough for a
    /// two-way choice and needs no gamma work.
    ///
    /// - Parameter fill: the colour the text will sit on.
    /// - Returns: near-white for a dark fill, near-black for a light one.
    static func textColor(on fill: PixelColor) -> PixelColor {
        let luma = 0.299 * Double(fill.red) + 0.587 * Double(fill.green) + 0.114 * Double(fill.blue)
        return luma < 140
            ? PixelColor(red: 255, green: 255, blue: 255, alpha: 255)
            : PixelColor(red: 17, green: 17, blue: 20, alpha: 255)
    }
}
