@testable import PixelPeeper
import Testing

@Suite("PixelColor hex parsing")
struct PixelColorHexParsingTests {
    @Test("parses 6-digit hex with implicit alpha 255")
    func parsesSixDigitHex() throws {
        let color = try PixelColor(hex: "#804020")

        #expect(color.red == 128)
        #expect(color.green == 64)
        #expect(color.blue == 32)
        #expect(color.alpha == 255)
    }

    @Test("parses 8-digit hex with explicit alpha")
    func parsesEightDigitHex() throws {
        let color = try PixelColor(hex: "#804020cc")

        #expect(color.red == 128)
        #expect(color.green == 64)
        #expect(color.blue == 32)
        #expect(color.alpha == 204)
    }

    @Test("parses uppercase hex")
    func parsesUppercase() throws {
        let color = try PixelColor(hex: "#FF00FF")

        #expect(color.red == 255)
        #expect(color.green == 0)
        #expect(color.blue == 255)
        #expect(color.alpha == 255)
    }

    @Test("parses mixed case hex")
    func parsesMixedCase() throws {
        let color = try PixelColor(hex: "#aAbBcC")

        #expect(color.red == 0xAA)
        #expect(color.green == 0xBB)
        #expect(color.blue == 0xCC)
    }

    @Test("round-trips through hex property for 8-digit")
    func roundTripsEightDigit() throws {
        let original = PixelColor(red: 128, green: 64, blue: 32, alpha: 255)
        let roundTripped = try PixelColor(hex: original.hex)

        #expect(roundTripped == original)
    }

    @Test("throws invalidHexColor for missing hash prefix")
    func throwsForMissingHash() {
        #expect(throws: PixelPeeperError.invalidHexColor("804020")) {
            try PixelColor(hex: "804020")
        }
    }

    @Test("throws invalidHexColor for wrong length")
    func throwsForWrongLength() {
        #expect(throws: PixelPeeperError.invalidHexColor("#8040")) {
            try PixelColor(hex: "#8040")
        }
    }

    @Test("throws invalidHexColor for non-hex characters")
    func throwsForNonHexCharacters() {
        #expect(throws: PixelPeeperError.invalidHexColor("#gggggg")) {
            try PixelColor(hex: "#gggggg")
        }
    }
}
