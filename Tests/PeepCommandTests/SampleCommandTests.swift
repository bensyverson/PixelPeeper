@testable import PeepCommand
import PixelPeeper
import Testing

@Suite("SampleCommand")
struct SampleCommandTests {
    // MARK: - Argument parsing

    @Test("parses image path and coordinates")
    func parsesArguments() throws {
        let command = try PeepCommand.parseAsRoot(["sample", "photo.png", "10", "20"])
        let sample = try #require(command as? SampleCommand)

        #expect(sample.image == "photo.png")
        #expect(sample.x == 10)
        #expect(sample.y == 20)
    }

    @Test("parses --format hex option")
    func parsesFormatHex() throws {
        let command = try PeepCommand.parseAsRoot(["sample", "a.png", "0", "0", "--format", "hex"])
        let sample = try #require(command as? SampleCommand)

        #expect(sample.format == .hex)
    }

    @Test("parses --format text option")
    func parsesFormatText() throws {
        let command = try PeepCommand.parseAsRoot(["sample", "a.png", "0", "0", "--format", "text"])
        let sample = try #require(command as? SampleCommand)

        #expect(sample.format == .text)
    }

    @Test("parses --format json option")
    func parsesFormatJSON() throws {
        let command = try PeepCommand.parseAsRoot(["sample", "a.png", "0", "0", "--format", "json"])
        let sample = try #require(command as? SampleCommand)

        #expect(sample.format == .json)
    }

    @Test("parses --scale option")
    func parsesScale() throws {
        let command = try PeepCommand.parseAsRoot(["sample", "a.png", "0", "0", "--scale", "3"])
        let sample = try #require(command as? SampleCommand)

        #expect(sample.scale == 3)
    }

    @Test("defaults format to hex, scale to 2")
    func defaults() throws {
        let command = try PeepCommand.parseAsRoot(["sample", "a.png", "0", "0"])
        let sample = try #require(command as? SampleCommand)

        #expect(sample.format == .hex)
        #expect(sample.scale == 2)
    }

    // MARK: - Output formatting

    @Test("formats color as hex string")
    func hexFormatting() {
        let color = PixelColor(red: 128, green: 64, blue: 32, alpha: 255)
        let output = SampleCommand.formatHex(color)

        #expect(output == "#804020ff")
    }

    @Test("formats color as text with labeled channels")
    func textFormatting() {
        let color = PixelColor(red: 128, green: 64, blue: 32, alpha: 255)
        let output = SampleCommand.formatText(color)

        #expect(output.contains("R: 128"))
        #expect(output.contains("G: 64"))
        #expect(output.contains("B: 32"))
        #expect(output.contains("A: 255"))
    }

    @Test("formats color as JSON with integer values")
    func jsonFormatting() throws {
        let color = PixelColor(red: 128, green: 64, blue: 32, alpha: 255)
        let output = try SampleCommand.formatJSON(color)

        #expect(output.contains("\"red\" : 128"))
        #expect(output.contains("\"green\" : 64"))
        #expect(output.contains("\"blue\" : 32"))
        #expect(output.contains("\"alpha\" : 255"))
    }
}
