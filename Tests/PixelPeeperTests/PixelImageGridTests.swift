import CoreGraphics
@testable import PixelPeeper
import Testing

@Suite("PixelImage labelled grid")
struct PixelImageGridTests {
    /// A deterministic, non-uniform source image so a blit can be checked byte for byte.
    static func source(width: Int, height: Int) -> PixelImage {
        var pixels = [UInt8]()
        pixels.reserveCapacity(width * height * 4)
        for y in 0 ..< height {
            for x in 0 ..< width {
                pixels.append(UInt8((x * 7) % 256))
                pixels.append(UInt8((y * 11) % 256))
                pixels.append(128)
                pixels.append(255)
            }
        }
        return PixelImage(width: width, height: height, pixels: pixels)
    }

    static let image: PixelImage = source(width: 200, height: 100)
    static let options = GridOptions(step: 50)

    static func layout(pixelsPerPoint: Double, origin: CGPoint = .zero) -> GridLayout {
        GridLayout(
            imageWidth: image.width, imageHeight: image.height,
            options: options, pixelsPerPoint: pixelsPerPoint, origin: origin,
        )
    }

    // MARK: - Size and blit

    @Test
    func `the gridded image is the source plus its gutters`() throws {
        let result = try Self.image.withGrid(Self.options, pixelsPerPoint: 2)
        let layout = Self.layout(pixelsPerPoint: 2)

        #expect(result.width == layout.width)
        #expect(result.height == layout.height)
    }

    @Test
    func `rulers mode leaves the page pixels byte-identical`() throws {
        let result = try Self.image.withGrid(
            GridOptions(mode: .rulers, step: 50), pixelsPerPoint: 2,
        )
        let layout = Self.layout(pixelsPerPoint: 2)
        let page = try result.cropped(
            x: layout.leftGutter, y: layout.topGutter,
            width: Self.image.width, height: Self.image.height,
        )

        #expect(page.pixels == Self.image.pixels)
    }

    @Test
    func `lines mode marks the page at every step column`() throws {
        let result = try Self.image.withGrid(Self.options, pixelsPerPoint: 2)
        let layout = Self.layout(pixelsPerPoint: 2)
        let onLine = try result.color(atX: layout.leftGutter + 100, y: layout.topGutter + 10)
        let offLine = try result.color(atX: layout.leftGutter + 105, y: layout.topGutter + 10)

        #expect(try onLine != (Self.image.color(atX: 100, y: 10)))
        #expect(try offLine == (Self.image.color(atX: 105, y: 10)))
    }

    // MARK: - Tick geometry

    @Test
    func `a ruler tick sits at the expected pixel column for the step and scale`() throws {
        let result = try Self.image.withGrid(Self.options, pixelsPerPoint: 2)
        let layout = Self.layout(pixelsPerPoint: 2)
        let probeY = layout.topGutter - 1
        let background = try result.color(atX: 0, y: 0)

        // step 50 at 2 px/pt lands ticks 100 image px apart.
        #expect(try result.color(atX: layout.leftGutter, y: probeY) != background)
        #expect(try result.color(atX: layout.leftGutter + 100, y: probeY) != background)
        // …and nowhere in between.
        #expect(try result.color(atX: layout.leftGutter + 50, y: probeY) == background)
        #expect(try result.color(atX: layout.leftGutter + 99, y: probeY) == background)
    }

    @Test
    func `a left ruler tick sits at the expected pixel row`() throws {
        let result = try Self.image.withGrid(GridOptions(step: 50), pixelsPerPoint: 1)
        let layout = Self.layout(pixelsPerPoint: 1)
        let probeX = layout.leftGutter - 1
        let background = try result.color(atX: 0, y: 0)

        #expect(try result.color(atX: probeX, y: layout.topGutter) != background)
        #expect(try result.color(atX: probeX, y: layout.topGutter + 50) != background)
        #expect(try result.color(atX: probeX, y: layout.topGutter + 25) == background)
    }

    // MARK: - Labels are source units

    @Test
    func `a label at scale 2 reads the source number, not the pixel number`() throws {
        let twoX = try Self.image.withGrid(Self.options, pixelsPerPoint: 2)
        let oneX = try Self.image.withGrid(Self.options, pixelsPerPoint: 1)
        let layoutTwo = Self.layout(pixelsPerPoint: 2)
        let layoutOne = Self.layout(pixelsPerPoint: 1)

        // At 2 px/pt the tick 100 px in reads "50"; at 1 px/pt the tick 50 px in reads "50".
        let fiftyAtTwoX = try twoX.cropped(
            x: layoutTwo.leftGutter + 100, y: 0, width: 20, height: layoutTwo.topGutter,
        )
        let fiftyAtOneX = try oneX.cropped(
            x: layoutOne.leftGutter + 50, y: 0, width: 20, height: layoutOne.topGutter,
        )
        // …while the tick 100 px in reads "100" at 1 px/pt.
        let hundredAtOneX = try oneX.cropped(
            x: layoutOne.leftGutter + 100, y: 0, width: 20, height: layoutOne.topGutter,
        )

        #expect(fiftyAtTwoX.pixels == fiftyAtOneX.pixels)
        #expect(fiftyAtTwoX.pixels != hundredAtOneX.pixels)
    }

    @Test
    func `a crop origin shifts the printed numbers`() throws {
        let plain = try Self.image.withGrid(Self.options, pixelsPerPoint: 2)
        let cropped = try Self.image.withGrid(
            Self.options, pixelsPerPoint: 2, origin: CGPoint(x: 900, y: 0),
        )
        let layout = Self.layout(pixelsPerPoint: 2)

        // Same geometry, different ink: the gutters must differ.
        #expect(cropped.width == plain.width)
        #expect(cropped.height == plain.height)
        let plainGutter = try plain.cropped(x: 0, y: 0, width: plain.width, height: layout.topGutter)
        let croppedGutter = try cropped.cropped(x: 0, y: 0, width: cropped.width, height: layout.topGutter)
        #expect(plainGutter.pixels != croppedGutter.pixels)
    }

    // MARK: - Errors

    @Test
    func `a non-positive scale is refused`() {
        #expect(throws: PixelPeeperError.invalidOverlayScale(0)) {
            _ = try Self.image.withGrid(Self.options, pixelsPerPoint: 0)
        }
    }

    @Test
    func `a non-positive step is refused`() {
        #expect(throws: PixelPeeperError.invalidGridStep(0)) {
            _ = try Self.image.withGrid(GridOptions(step: 0), pixelsPerPoint: 2)
        }
    }
}
