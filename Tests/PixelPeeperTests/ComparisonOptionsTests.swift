import Foundation
@testable import PixelPeeper
import Testing

@Suite("ComparisonOptions")
struct ComparisonOptionsTests {
    @Test("default options use error strategy for dimension mismatch")
    func defaultIsError() {
        let options = ComparisonOptions.default

        #expect(options.dimensionMismatch == .error)
    }

    @Test("conforms to Equatable")
    func equatable() {
        let a = ComparisonOptions(dimensionMismatch: .error)
        let b = ComparisonOptions(dimensionMismatch: .error)
        let c = ComparisonOptions(dimensionMismatch: .resizeToSmallest)

        #expect(a == b)
        #expect(a != c)
    }

    @Test("round-trips through JSON encoding and decoding")
    func codableRoundTrip() throws {
        let original = ComparisonOptions(dimensionMismatch: .resizeToSmallest)

        let data = try JSONEncoder().encode(original)
        let decoded: ComparisonOptions = try JSONDecoder().decode(ComparisonOptions.self, from: data)

        #expect(decoded == original)
    }
}
