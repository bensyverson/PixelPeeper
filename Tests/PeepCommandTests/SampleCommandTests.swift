@testable import PeepCommand
import PixelPeeper
import Testing

@Suite("SampleCommand")
struct SampleCommandTests {
    // MARK: - Argument parsing

    @Test
    func `parses image path and coordinates`() throws {
        let command = try PeepCommand.parseAsRoot(["sample", "photo.png", "10", "20"])
        let sample = try #require(command as? SampleCommand)

        #expect(sample.image == "photo.png")
        #expect(sample.x == 10)
        #expect(sample.y == 20)
    }

    @Test
    func `parses --format hex option`() throws {
        let command = try PeepCommand.parseAsRoot(["sample", "a.png", "0", "0", "--format", "hex"])
        let sample = try #require(command as? SampleCommand)

        #expect(sample.format == .hex)
    }

    @Test
    func `parses --format text option`() throws {
        let command = try PeepCommand.parseAsRoot(["sample", "a.png", "0", "0", "--format", "text"])
        let sample = try #require(command as? SampleCommand)

        #expect(sample.format == .text)
    }

    @Test
    func `parses --format json option`() throws {
        let command = try PeepCommand.parseAsRoot(["sample", "a.png", "0", "0", "--format", "json"])
        let sample = try #require(command as? SampleCommand)

        #expect(sample.format == .json)
    }

    @Test
    func `parses --scale option`() throws {
        let command = try PeepCommand.parseAsRoot(["sample", "a.png", "0", "0", "--scale", "3"])
        let sample = try #require(command as? SampleCommand)

        #expect(sample.scale == 3)
    }

    @Test
    func `defaults format to hex, scale to 2`() throws {
        let command = try PeepCommand.parseAsRoot(["sample", "a.png", "0", "0"])
        let sample = try #require(command as? SampleCommand)

        #expect(sample.format == .hex)
        #expect(sample.scale == 2)
    }

    // MARK: - Output formatting

    @Test
    func `formats color as hex string`() {
        let color = PixelColor(red: 128, green: 64, blue: 32, alpha: 255)
        let output = SampleCommand.formatHex(color)

        #expect(output == "#804020ff")
    }

    @Test
    func `formats color as text with labeled channels`() {
        let color = PixelColor(red: 128, green: 64, blue: 32, alpha: 255)
        let output = SampleCommand.formatText(color)

        #expect(output.contains("R: 128"))
        #expect(output.contains("G: 64"))
        #expect(output.contains("B: 32"))
        #expect(output.contains("A: 255"))
    }

    @Test
    func `formats color as JSON with integer values`() throws {
        let color = PixelColor(red: 128, green: 64, blue: 32, alpha: 255)
        let output = try SampleCommand.formatJSON(color)

        #expect(output.contains("\"red\" : 128"))
        #expect(output.contains("\"green\" : 64"))
        #expect(output.contains("\"blue\" : 32"))
        #expect(output.contains("\"alpha\" : 255"))
    }
}
