import Foundation
@testable import PixelPeeper
import Testing

@Suite("LineSample")
struct LineSampleTests {
    @Test
    func `stores x, y, and color`() {
        let color = PixelColor(red: 128, green: 64, blue: 32, alpha: 255)
        let sample = LineSample(x: 10, y: 20, color: color)

        #expect(sample.x == 10)
        #expect(sample.y == 20)
        #expect(sample.color == color)
    }

    @Test
    func `conforms to Equatable`() {
        let color = PixelColor(red: 128, green: 64, blue: 32, alpha: 255)
        let a = LineSample(x: 10, y: 20, color: color)
        let b = LineSample(x: 10, y: 20, color: color)
        let c = LineSample(x: 5, y: 20, color: color)

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `conforms to Codable`() throws {
        let color = PixelColor(red: 128, green: 64, blue: 32, alpha: 255)
        let sample = LineSample(x: 10, y: 20, color: color)

        let data = try JSONEncoder().encode(sample)
        let decoded = try JSONDecoder().decode(LineSample.self, from: data)

        #expect(decoded == sample)
    }
}
