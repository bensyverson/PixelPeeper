import Foundation
@testable import PixelPeeper
import Testing

@Suite("EightBitSteps")
struct EightBitStepsTests {
    @Test
    func `holds its value in 8-bit channel steps`() {
        let steps = EightBitSteps(127.5)

        #expect(steps.value == 127.5)
    }

    @Test
    func `reads a float or integer literal as steps`() {
        let fromFloat: EightBitSteps = 2.55
        let fromInteger: EightBitSteps = 255

        #expect(fromFloat.value == 2.55)
        #expect(fromInteger.value == 255.0)
    }

    @Test
    func `orders by value, so a threshold reads as a comparison`() {
        let small = EightBitSteps(0.5)
        let large = EightBitSteps(1.0)

        #expect(small < large)
        #expect(large > small)
        #expect(small <= 0.5)
        #expect(!(large < 1.0))
    }

    @Test
    func `names its unit when printed`() {
        #expect(EightBitSteps(1.25).description == "1.25 steps")
    }

    @Test
    func `encodes as a bare number`() throws {
        let data = try JSONEncoder().encode(EightBitSteps(63.75))
        let json = try #require(String(data: data, encoding: .utf8))

        #expect(json == "63.75")
    }

    @Test
    func `round-trips through JSON`() throws {
        let original = EightBitSteps(191.25)

        let data = try JSONEncoder().encode(original)
        let decoded: EightBitSteps = try JSONDecoder().decode(EightBitSteps.self, from: data)

        #expect(decoded == original)
    }
}
