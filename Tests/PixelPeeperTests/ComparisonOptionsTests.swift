import Foundation
@testable import PixelPeeper
import Testing

@Suite("ComparisonOptions")
struct ComparisonOptionsTests {
    @Test
    func `default options use error strategy for dimension mismatch`() {
        let options = ComparisonOptions.default

        #expect(options.dimensionMismatch == .error)
    }

    @Test
    func `conforms to Equatable`() {
        let a = ComparisonOptions(dimensionMismatch: .error)
        let b = ComparisonOptions(dimensionMismatch: .error)
        let c = ComparisonOptions(dimensionMismatch: .resizeToSmallest)

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `round-trips through JSON encoding and decoding`() throws {
        let original = ComparisonOptions(dimensionMismatch: .resizeToSmallest)

        let data = try JSONEncoder().encode(original)
        let decoded: ComparisonOptions = try JSONDecoder().decode(ComparisonOptions.self, from: data)

        #expect(decoded == original)
    }
}
