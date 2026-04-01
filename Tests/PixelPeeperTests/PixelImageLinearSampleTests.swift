@testable import PixelPeeper
import Testing

@Suite("PixelImage linear sampling")
struct PixelImageLinearSampleTests {
    /// 3x1 image: red, green, blue
    static let horizontalImage = PixelImage(width: 3, height: 1, pixels: [
        255, 0, 0, 255,
        0, 255, 0, 255,
        0, 0, 255, 255,
    ])

    @Test("samples endpoints and midpoint on a horizontal line")
    func samplesHorizontalLine() throws {
        let samples = try Self.horizontalImage.linearSample(
            from: (x: 0, y: 0), to: (x: 2, y: 0), steps: 3,
        )

        #expect(samples.count == 3)
        #expect(samples[0].x == 0)
        #expect(samples[0].y == 0)
        #expect(samples[0].color == PixelColor(red: 255, green: 0, blue: 0, alpha: 255))
        #expect(samples[1].x == 1)
        #expect(samples[1].color == PixelColor(red: 0, green: 255, blue: 0, alpha: 255))
        #expect(samples[2].x == 2)
        #expect(samples[2].color == PixelColor(red: 0, green: 0, blue: 255, alpha: 255))
    }

    @Test("samples two endpoints only with steps=2")
    func samplesTwoEndpoints() throws {
        let samples = try Self.horizontalImage.linearSample(
            from: (x: 0, y: 0), to: (x: 2, y: 0), steps: 2,
        )

        #expect(samples.count == 2)
        #expect(samples[0].x == 0)
        #expect(samples[1].x == 2)
    }

    @Test("samples vertical line")
    func samplesVerticalLine() throws {
        // 1x3 image: red, green, blue
        let image = PixelImage(width: 1, height: 3, pixels: [
            255, 0, 0, 255,
            0, 255, 0, 255,
            0, 0, 255, 255,
        ])

        let samples = try image.linearSample(
            from: (x: 0, y: 0), to: (x: 0, y: 2), steps: 3,
        )

        #expect(samples.count == 3)
        #expect(samples[0].y == 0)
        #expect(samples[1].y == 1)
        #expect(samples[2].y == 2)
    }

    @Test("throws invalidStepCount for steps less than 2")
    func throwsForTooFewSteps() {
        #expect(throws: PixelPeeperError.invalidStepCount(1)) {
            try Self.horizontalImage.linearSample(
                from: (x: 0, y: 0), to: (x: 2, y: 0), steps: 1,
            )
        }
    }

    @Test("throws coordinateOutOfBounds for out-of-bounds start")
    func throwsForOutOfBoundsStart() {
        #expect(throws: PixelPeeperError.self) {
            try Self.horizontalImage.linearSample(
                from: (x: -1, y: 0), to: (x: 2, y: 0), steps: 2,
            )
        }
    }

    @Test("throws coordinateOutOfBounds for out-of-bounds end")
    func throwsForOutOfBoundsEnd() {
        #expect(throws: PixelPeeperError.self) {
            try Self.horizontalImage.linearSample(
                from: (x: 0, y: 0), to: (x: 5, y: 0), steps: 2,
            )
        }
    }
}
