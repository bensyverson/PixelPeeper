import Foundation
@testable import PixelPeeper
import Testing

@Suite("ImageComparisonResult")
struct ImageComparisonResultTests {
    @Test("stores overall and per-channel MAE values")
    func storesValues() {
        let result = ImageComparisonResult(mae: 50.0, red: 100.0, green: 0.0, blue: 100.0, alpha: 0.0)

        #expect(result.mae == 50.0)
        #expect(result.red == 100.0)
        #expect(result.green == 0.0)
        #expect(result.blue == 100.0)
        #expect(result.alpha == 0.0)
    }

    @Test("conforms to Equatable")
    func equatable() {
        let a = ImageComparisonResult(mae: 1.0, red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        let b = ImageComparisonResult(mae: 1.0, red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        let c = ImageComparisonResult(mae: 2.0, red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

        #expect(a == b)
        #expect(a != c)
    }

    @Test("conforms to Hashable")
    func hashable() {
        let a = ImageComparisonResult(mae: 1.0, red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        let b = ImageComparisonResult(mae: 1.0, red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

        #expect(a.hashValue == b.hashValue)
    }

    @Test("round-trips through JSON encoding and decoding")
    func codableRoundTrip() throws {
        let original = ImageComparisonResult(mae: 42.5, red: 10.0, green: 20.0, blue: 30.0, alpha: 0.5)

        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let data = try encoder.encode(original)
        let decoded: ImageComparisonResult = try JSONDecoder().decode(ImageComparisonResult.self, from: data)

        #expect(decoded == original)
    }

    @Test("JSON encoding uses expected keys")
    func jsonKeys() throws {
        let result = ImageComparisonResult(mae: 1.0, red: 2.0, green: 3.0, blue: 4.0, alpha: 5.0)

        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let data = try encoder.encode(result)
        let json = try #require(String(data: data, encoding: .utf8))

        #expect(json.contains("\"mae\""))
        #expect(json.contains("\"red\""))
        #expect(json.contains("\"green\""))
        #expect(json.contains("\"blue\""))
        #expect(json.contains("\"alpha\""))
    }
}
