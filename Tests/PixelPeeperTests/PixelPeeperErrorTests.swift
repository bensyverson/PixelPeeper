@testable import PixelPeeper
import Testing

@Suite("PixelPeeperError")
struct PixelPeeperErrorTests {
    @Test
    func `fileNotFound includes the path in its description`() {
        let error = PixelPeeperError.fileNotFound(path: "/tmp/missing.png")

        #expect(error.description.contains("/tmp/missing.png"))
    }

    @Test
    func `imageLoadFailed includes the path and reason in its description`() {
        let error = PixelPeeperError.imageLoadFailed(path: "/tmp/bad.png", reason: "corrupt header")

        #expect(error.description.contains("/tmp/bad.png"))
        #expect(error.description.contains("corrupt header"))
    }

    @Test
    func `pixelExtractionFailed includes the path in its description`() {
        let error = PixelPeeperError.pixelExtractionFailed(path: "/tmp/weird.png")

        #expect(error.description.contains("/tmp/weird.png"))
    }

    @Test
    func `dimensionMismatch includes both dimensions in its description`() {
        let error = PixelPeeperError.dimensionMismatch(
            width1: 100, height1: 200,
            width2: 300, height2: 400,
        )

        #expect(error.description.contains("100"))
        #expect(error.description.contains("200"))
        #expect(error.description.contains("300"))
        #expect(error.description.contains("400"))
    }

    @Test
    func `coordinateOutOfBounds includes coordinates and dimensions in its description`() {
        let error = PixelPeeperError.coordinateOutOfBounds(x: 5, y: 10, width: 3, height: 8)

        #expect(error.description.contains("5"))
        #expect(error.description.contains("10"))
        #expect(error.description.contains("3"))
        #expect(error.description.contains("8"))
    }

    @Test
    func `invalidHexColor includes the hex string in its description`() {
        let error = PixelPeeperError.invalidHexColor("zzzzzz")

        #expect(error.description.contains("zzzzzz"))
    }

    @Test
    func `invalidCropRegion includes region and image dimensions in its description`() {
        let error = PixelPeeperError.invalidCropRegion(
            x: 10, y: 20, width: 50, height: 60,
            imageWidth: 100, imageHeight: 200,
        )

        #expect(error.description.contains("10"))
        #expect(error.description.contains("20"))
        #expect(error.description.contains("50"))
        #expect(error.description.contains("60"))
        #expect(error.description.contains("100"))
        #expect(error.description.contains("200"))
    }

    @Test
    func `invalidStepCount includes the step count in its description`() {
        let error = PixelPeeperError.invalidStepCount(1)

        #expect(error.description.contains("1"))
    }

    @Test
    func `invalidOverlayScale includes the scale in its description`() {
        let error = PixelPeeperError.invalidOverlayScale(0)

        #expect(error.description.contains("0"))
        #expect(error.description.contains("source unit"))
    }

    @Test
    func `invalidGridStep includes the step in its description`() {
        let error = PixelPeeperError.invalidGridStep(-4)

        #expect(error.description.contains("-4"))
        #expect(error.description.contains("source unit"))
    }

    @Test
    func `overlayRenderFailed includes the bitmap size in its description`() {
        let error = PixelPeeperError.overlayRenderFailed(width: 320, height: 240)

        #expect(error.description.contains("320"))
        #expect(error.description.contains("240"))
    }

    @Test
    func `conforms to Equatable`() {
        let a = PixelPeeperError.fileNotFound(path: "/a.png")
        let b = PixelPeeperError.fileNotFound(path: "/a.png")
        let c = PixelPeeperError.fileNotFound(path: "/b.png")

        #expect(a == b)
        #expect(a != c)
    }
}
