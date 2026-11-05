@testable import PeepCommand
import PixelPeeper
import Testing

@Suite("CompareCommand")
struct CompareCommandTests {
    // MARK: - Argument parsing

    @Test
    func `parses two positional image paths`() throws {
        let command = try PeepCommand.parseAsRoot(["compare", "image1.png", "image2.png"])
        let compare = try #require(command as? CompareCommand)

        #expect(compare.image1 == "image1.png")
        #expect(compare.image2 == "image2.png")
    }

    @Test
    func `parses --format text option`() throws {
        let command = try PeepCommand.parseAsRoot(["compare", "a.png", "b.png", "--format", "text"])
        let compare = try #require(command as? CompareCommand)

        #expect(compare.format == .text)
    }

    @Test
    func `parses --format json option`() throws {
        let command = try PeepCommand.parseAsRoot(["compare", "a.png", "b.png", "--format", "json"])
        let compare = try #require(command as? CompareCommand)

        #expect(compare.format == .json)
    }

    @Test
    func `parses --resize flag`() throws {
        let command = try PeepCommand.parseAsRoot(["compare", "a.png", "b.png", "--resize"])
        let compare = try #require(command as? CompareCommand)

        #expect(compare.resize == true)
    }

    @Test
    func `parses --threshold option`() throws {
        let command = try PeepCommand.parseAsRoot(["compare", "a.png", "b.png", "--threshold", "5.0"])
        let compare = try #require(command as? CompareCommand)

        #expect(compare.threshold == 5.0)
    }

    @Test
    func `parses --scale option`() throws {
        let command = try PeepCommand.parseAsRoot(["compare", "a.png", "b.png", "--scale", "3"])
        let compare = try #require(command as? CompareCommand)

        #expect(compare.scale == 3)
    }

    @Test
    func `defaults format to text, resize to false, threshold to nil, scale to 2`() throws {
        let command = try PeepCommand.parseAsRoot(["compare", "a.png", "b.png"])
        let compare = try #require(command as? CompareCommand)

        #expect(compare.format == .text)
        #expect(compare.resize == false)
        #expect(compare.threshold == nil)
        #expect(compare.scale == 2)
    }

    // MARK: - Output formatting

    @Test
    func `formats text output with overall and per-channel MAE`() {
        let result = ImageComparisonResult(mae: 2.1, maeSteps: 5.355, red: 1.0, green: 0.1, blue: 1.0, alpha: 0.0)
        let output = CompareCommand.formatText(result)

        #expect(output.contains("MAE: 2.1"))
        #expect(output.contains("  R: 1.0"))
        #expect(output.contains("  G: 0.1"))
        #expect(output.contains("  B: 1.0"))
        #expect(output.contains("  A: 0.0"))
    }

    @Test
    func `formats JSON output with all fields`() throws {
        let result = ImageComparisonResult(mae: 2.1, maeSteps: 5.355, red: 1.0, green: 0.1, blue: 1.0, alpha: 0.0)
        let output = try CompareCommand.formatJSON(result)

        #expect(output.contains("\"mae\""))
        #expect(output.contains("\"maeSteps\" : 5.355"))
        #expect(output.contains("\"red\""))
        #expect(output.contains("\"green\""))
        #expect(output.contains("\"blue\""))
        #expect(output.contains("\"alpha\""))
    }
}
