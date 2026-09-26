import Foundation
@testable import PixelPeeper
import Testing

@Suite("EightBitSteps")
struct EightBitStepsTests {
    @Test("holds its value in 8-bit channel steps")
    func holdsValue() {
        let steps = EightBitSteps(127.5)

        #expect(steps.value == 127.5)
    }

    @Test("reads a float or integer literal as steps")
    func literals() {
        let fromFloat: EightBitSteps = 2.55
        let fromInteger: EightBitSteps = 255

        #expect(fromFloat.value == 2.55)
        #expect(fromInteger.value == 255.0)
    }

    @Test("orders by value, so a threshold reads as a comparison")
    func comparable() {
        let small = EightBitSteps(0.5)
        let large = EightBitSteps(1.0)

        #expect(small < large)
        #expect(large > small)
        #expect(small <= 0.5)
        #expect(!(large < 1.0))
    }

    @Test("names its unit when printed")
    func description() {
        #expect(EightBitSteps(1.25).description == "1.25 steps")
    }

    @Test("encodes as a bare number")
    func encodesAsNumber() throws {
        let data = try JSONEncoder().encode(EightBitSteps(63.75))
        let json = try #require(String(data: data, encoding: .utf8))

        #expect(json == "63.75")
    }

    @Test("round-trips through JSON")
    func codableRoundTrip() throws {
        let original = EightBitSteps(191.25)

        let data = try JSONEncoder().encode(original)
        let decoded: EightBitSteps = try JSONDecoder().decode(EightBitSteps.self, from: data)

        #expect(decoded == original)
    }
}
