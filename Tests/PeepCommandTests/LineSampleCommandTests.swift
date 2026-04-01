@testable import PeepCommand
import PixelPeeper
import Testing

@Suite("LineSampleCommand")
struct LineSampleCommandTests {
    // MARK: - Argument parsing

    @Test("parses image path and required options")
    func parsesArguments() throws {
        let command = try PeepCommand.parseAsRoot([
            "linesample", "photo.png",
            "--x1", "0", "--y1", "0",
            "--x2", "100", "--y2", "50",
            "--steps", "10",
        ])
        let lineSample = try #require(command as? LineSampleCommand)

        #expect(lineSample.image == "photo.png")
        #expect(lineSample.x1 == 0)
        #expect(lineSample.y1 == 0)
        #expect(lineSample.x2 == 100)
        #expect(lineSample.y2 == 50)
        #expect(lineSample.steps == 10)
    }

    @Test("parses --format text option")
    func parsesFormatText() throws {
        let command = try PeepCommand.parseAsRoot([
            "linesample", "a.png",
            "--x1", "0", "--y1", "0",
            "--x2", "1", "--y2", "1",
            "--steps", "2",
            "--format", "text",
        ])
        let lineSample = try #require(command as? LineSampleCommand)

        #expect(lineSample.format == .text)
    }

    @Test("parses --format json option")
    func parsesFormatJSON() throws {
        let command = try PeepCommand.parseAsRoot([
            "linesample", "a.png",
            "--x1", "0", "--y1", "0",
            "--x2", "1", "--y2", "1",
            "--steps", "2",
            "--format", "json",
        ])
        let lineSample = try #require(command as? LineSampleCommand)

        #expect(lineSample.format == .json)
    }

    @Test("parses --scale option")
    func parsesScale() throws {
        let command = try PeepCommand.parseAsRoot([
            "linesample", "a.png",
            "--x1", "0", "--y1", "0",
            "--x2", "1", "--y2", "1",
            "--steps", "2",
            "--scale", "3",
        ])
        let lineSample = try #require(command as? LineSampleCommand)

        #expect(lineSample.scale == 3)
    }

    @Test("defaults format to text and scale to 2")
    func defaults() throws {
        let command = try PeepCommand.parseAsRoot([
            "linesample", "a.png",
            "--x1", "0", "--y1", "0",
            "--x2", "1", "--y2", "1",
            "--steps", "2",
        ])
        let lineSample = try #require(command as? LineSampleCommand)

        #expect(lineSample.format == .text)
        #expect(lineSample.scale == 2)
    }

    // MARK: - Output formatting

    @Test("formats samples as text with coordinates and hex colors")
    func textFormatting() {
        let samples = [
            LineSample(x: 0, y: 0, color: PixelColor(red: 255, green: 0, blue: 0, alpha: 255)),
            LineSample(x: 50, y: 25, color: PixelColor(red: 0, green: 255, blue: 0, alpha: 255)),
        ]

        let output = LineSampleCommand.formatText(samples)

        #expect(output.contains("0, 0: #ff0000ff"))
        #expect(output.contains("50, 25: #00ff00ff"))
    }

    @Test("formats samples as JSON array")
    func jsonFormatting() throws {
        let samples = [
            LineSample(x: 10, y: 20, color: PixelColor(red: 128, green: 64, blue: 32, alpha: 255)),
        ]

        let output = try LineSampleCommand.formatJSON(samples)

        #expect(output.contains("\"x\" : 10"))
        #expect(output.contains("\"y\" : 20"))
    }
}
