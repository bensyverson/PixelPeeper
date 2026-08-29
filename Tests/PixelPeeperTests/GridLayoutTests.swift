import CoreGraphics
@testable import PixelPeeper
import Testing

@Suite("GridLayout")
struct GridLayoutTests {
    // MARK: - Ticks

    @Test
    func `ticks land on multiples of the step, in source coordinates`() {
        let ticks = GridLayout.ticks(fromOrigin: 0, acrossPixels: 200, pixelsPerPoint: 2, step: 50)

        #expect(ticks.map(\.position) == [0, 50])
        #expect(ticks.map(\.pixelOffset) == [0, 100])
    }

    @Test
    func `a crop origin shifts the labels, not the pixel offsets`() {
        let ticks = GridLayout.ticks(fromOrigin: 900, acrossPixels: 200, pixelsPerPoint: 2, step: 50)

        #expect(ticks.map(\.label) == ["900", "950"])
        #expect(ticks.map(\.pixelOffset) == [0, 100])
    }

    @Test
    func `a mid-step origin starts at the first whole step inside the crop`() {
        let ticks = GridLayout.ticks(fromOrigin: 910, acrossPixels: 200, pixelsPerPoint: 2, step: 50)

        #expect(ticks.map(\.position) == [950, 1000])
        #expect(ticks.map(\.pixelOffset) == [80, 180])
    }

    @Test
    func `no ticks for a non-positive step, scale or extent`() {
        #expect(GridLayout.ticks(fromOrigin: 0, acrossPixels: 200, pixelsPerPoint: 2, step: 0).isEmpty)
        #expect(GridLayout.ticks(fromOrigin: 0, acrossPixels: 200, pixelsPerPoint: 0, step: 50).isEmpty)
        #expect(GridLayout.ticks(fromOrigin: 0, acrossPixels: 0, pixelsPerPoint: 2, step: 50).isEmpty)
    }

    // MARK: - Layout

    @Test
    func `labels read source units, not pixels, at scale 2`() {
        let layout = GridLayout(
            imageWidth: 200, imageHeight: 100,
            options: GridOptions(step: 50), pixelsPerPoint: 2,
        )

        #expect(layout.columns.map(\.label) == ["0", "50"])
        #expect(layout.rows.map(\.label) == ["0"])
    }

    @Test
    func `at scale 1 the same image carries twice as many source units`() {
        let layout = GridLayout(
            imageWidth: 200, imageHeight: 100,
            options: GridOptions(step: 50), pixelsPerPoint: 1,
        )

        #expect(layout.columns.map(\.label) == ["0", "50", "100", "150"])
        #expect(layout.rows.map(\.label) == ["0", "50"])
    }

    @Test
    func `the origin is added to every label`() {
        let layout = GridLayout(
            imageWidth: 200, imageHeight: 100,
            options: GridOptions(step: 50), pixelsPerPoint: 2,
            origin: CGPoint(x: 900, y: 300),
        )

        #expect(layout.columns.map(\.label) == ["900", "950"])
        #expect(layout.rows.map(\.label) == ["300"])
    }

    @Test
    func `gutters default to the minimum when the labels are short`() {
        let layout = GridLayout(
            imageWidth: 200, imageHeight: 100,
            options: GridOptions(step: 50), pixelsPerPoint: 2,
        )

        #expect(layout.leftGutter == GridLayout.minimumGutter)
        #expect(layout.topGutter == GridLayout.minimumGutter)
    }

    @Test
    func `the left gutter widens for long row labels, clearing the tick marks`() {
        let layout = GridLayout(
            imageWidth: 200, imageHeight: 4000,
            options: GridOptions(step: 50), pixelsPerPoint: 1,
            origin: CGPoint(x: 0, y: 100_000),
        )
        let widest: Double = layout.rows.map { GridLayout.labelWidth($0.label) }.max() ?? 0

        #expect(layout.leftGutter > GridLayout.minimumGutter)
        #expect(Double(layout.leftGutter) >= widest + Double(GridLayout.labelInset * 2 + GridLayout.tickLength))
    }

    @Test
    func `the overlaid size is the image plus its gutters`() {
        let layout = GridLayout(
            imageWidth: 200, imageHeight: 100,
            options: GridOptions(step: 50), pixelsPerPoint: 2,
        )

        #expect(layout.width == 200 + layout.leftGutter)
        #expect(layout.height == 100 + layout.topGutter)
    }

    // MARK: - Options

    @Test
    func `grid options default to rulers plus lines at a 100-unit step`() {
        let options = GridOptions()

        #expect(options.mode == .rulersAndLines)
        #expect(options.step == 100)
    }

    @Test
    func `grid modes round-trip through their CLI spellings`() {
        #expect(GridOptions.Mode(rawValue: "lines") == .rulersAndLines)
        #expect(GridOptions.Mode(rawValue: "rulers") == .rulers)
        #expect(GridOptions.Mode.allCases.count == 2)
    }
}
