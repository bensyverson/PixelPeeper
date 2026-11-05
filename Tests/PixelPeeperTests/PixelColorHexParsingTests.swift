@testable import PixelPeeper
import Testing

@Suite("PixelColor hex parsing")
struct PixelColorHexParsingTests {
    @Test
    func `parses 6-digit hex with implicit alpha 255`() throws {
        let color = try PixelColor(hex: "#804020")

        #expect(color.red == 128)
        #expect(color.green == 64)
        #expect(color.blue == 32)
        #expect(color.alpha == 255)
    }

    @Test
    func `parses 8-digit hex with explicit alpha`() throws {
        let color = try PixelColor(hex: "#804020cc")

        #expect(color.red == 128)
        #expect(color.green == 64)
        #expect(color.blue == 32)
        #expect(color.alpha == 204)
    }

    @Test
    func `parses uppercase hex`() throws {
        let color = try PixelColor(hex: "#FF00FF")

        #expect(color.red == 255)
        #expect(color.green == 0)
        #expect(color.blue == 255)
        #expect(color.alpha == 255)
    }

    @Test
    func `parses mixed case hex`() throws {
        let color = try PixelColor(hex: "#aAbBcC")

        #expect(color.red == 0xAA)
        #expect(color.green == 0xBB)
        #expect(color.blue == 0xCC)
    }

    @Test
    func `round-trips through hex property for 8-digit`() throws {
        let original = PixelColor(red: 128, green: 64, blue: 32, alpha: 255)
        let roundTripped = try PixelColor(hex: original.hex)

        #expect(roundTripped == original)
    }

    @Test
    func `throws invalidHexColor for missing hash prefix`() {
        #expect(throws: PixelPeeperError.invalidHexColor("804020")) {
            try PixelColor(hex: "804020")
        }
    }

    @Test
    func `throws invalidHexColor for wrong length`() {
        #expect(throws: PixelPeeperError.invalidHexColor("#8040")) {
            try PixelColor(hex: "#8040")
        }
    }

    @Test
    func `throws invalidHexColor for non-hex characters`() {
        #expect(throws: PixelPeeperError.invalidHexColor("#gggggg")) {
            try PixelColor(hex: "#gggggg")
        }
    }
}
