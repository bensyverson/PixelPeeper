@testable import PixelPeeper
import Testing

@Suite("PixelPeeperError")
struct PixelPeeperErrorTests {
    @Test("fileNotFound includes the path in its description")
    func fileNotFoundDescription() {
        let error = PixelPeeperError.fileNotFound(path: "/tmp/missing.png")

        #expect(error.description.contains("/tmp/missing.png"))
    }

    @Test("imageLoadFailed includes the path and reason in its description")
    func imageLoadFailedDescription() {
        let error = PixelPeeperError.imageLoadFailed(path: "/tmp/bad.png", reason: "corrupt header")

        #expect(error.description.contains("/tmp/bad.png"))
        #expect(error.description.contains("corrupt header"))
    }

    @Test("pixelExtractionFailed includes the path in its description")
    func pixelExtractionFailedDescription() {
        let error = PixelPeeperError.pixelExtractionFailed(path: "/tmp/weird.png")

        #expect(error.description.contains("/tmp/weird.png"))
    }

    @Test("dimensionMismatch includes both dimensions in its description")
    func dimensionMismatchDescription() {
        let error = PixelPeeperError.dimensionMismatch(
            width1: 100, height1: 200,
            width2: 300, height2: 400
        )

        #expect(error.description.contains("100"))
        #expect(error.description.contains("200"))
        #expect(error.description.contains("300"))
        #expect(error.description.contains("400"))
    }

    @Test("coordinateOutOfBounds includes coordinates and dimensions in its description")
    func coordinateOutOfBoundsDescription() {
        let error = PixelPeeperError.coordinateOutOfBounds(x: 5, y: 10, width: 3, height: 8)

        #expect(error.description.contains("5"))
        #expect(error.description.contains("10"))
        #expect(error.description.contains("3"))
        #expect(error.description.contains("8"))
    }

    @Test("conforms to Equatable")
    func equatable() {
        let a = PixelPeeperError.fileNotFound(path: "/a.png")
        let b = PixelPeeperError.fileNotFound(path: "/a.png")
        let c = PixelPeeperError.fileNotFound(path: "/b.png")

        #expect(a == b)
        #expect(a != c)
    }
}
