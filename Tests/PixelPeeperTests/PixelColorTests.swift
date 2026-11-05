import Foundation
@testable import PixelPeeper
import Testing

@Suite("PixelColor")
struct PixelColorTests {
    @Test
    func `stores RGBA values`() {
        let color = PixelColor(red: 128, green: 64, blue: 32, alpha: 255)

        #expect(color.red == 128)
        #expect(color.green == 64)
        #expect(color.blue == 32)
        #expect(color.alpha == 255)
    }

    @Test
    func `conforms to Equatable`() {
        let a = PixelColor(red: 128, green: 64, blue: 32, alpha: 255)
        let b = PixelColor(red: 128, green: 64, blue: 32, alpha: 255)
        let c = PixelColor(red: 0, green: 0, blue: 0, alpha: 0)

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `conforms to Hashable`() {
        let a = PixelColor(red: 128, green: 64, blue: 32, alpha: 255)
        let b = PixelColor(red: 128, green: 64, blue: 32, alpha: 255)

        #expect(a.hashValue == b.hashValue)
    }

    @Test
    func `round-trips through JSON encoding and decoding`() throws {
        let original = PixelColor(red: 128, green: 64, blue: 32, alpha: 255)

        let data = try JSONEncoder().encode(original)
        let decoded: PixelColor = try JSONDecoder().decode(PixelColor.self, from: data)

        #expect(decoded == original)
    }

    @Test
    func `formats as hex string with RRGGBBAA`() {
        let color = PixelColor(red: 128, green: 64, blue: 32, alpha: 255)

        #expect(color.hex == "#804020ff")
    }

    @Test
    func `formats hex with leading zeros`() {
        let color = PixelColor(red: 0, green: 1, blue: 15, alpha: 0)

        #expect(color.hex == "#00010f00")
    }
}
