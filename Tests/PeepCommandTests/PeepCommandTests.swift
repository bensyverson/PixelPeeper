@testable import PeepCommand
import PixelPeeper
import Testing

@Suite("PeepCommand")
struct PeepCommandTests {
    // MARK: - Argument parsing

    @Test("parses two positional image paths")
    func parsesTwoArguments() throws {
        let command = try PeepCommand.parse(["image1.png", "image2.png"])

        #expect(command.image1 == "image1.png")
        #expect(command.image2 == "image2.png")
    }

    @Test("parses --json flag")
    func parsesJsonFlag() throws {
        let command = try PeepCommand.parse(["a.png", "b.png", "--json"])

        #expect(command.json == true)
    }

    @Test("parses --resize flag")
    func parsesResizeFlag() throws {
        let command = try PeepCommand.parse(["a.png", "b.png", "--resize"])

        #expect(command.resize == true)
    }

    @Test("parses --threshold option")
    func parsesThreshold() throws {
        let command = try PeepCommand.parse(["a.png", "b.png", "--threshold", "5.0"])

        #expect(command.threshold == 5.0)
    }

    @Test("defaults json, resize to false and threshold to nil")
    func defaults() throws {
        let command = try PeepCommand.parse(["a.png", "b.png"])

        #expect(command.json == false)
        #expect(command.resize == false)
        #expect(command.threshold == nil)
    }

    // MARK: - Output formatting

    @Test("formats text output with overall and per-channel MAE")
    func textFormatting() {
        let result = ImageComparisonResult(mae: 2.1, red: 1.0, green: 0.1, blue: 1.0, alpha: 0.0)
        let output = PeepCommand.formatText(result)

        #expect(output.contains("MAE: 2.1"))
        #expect(output.contains("  R: 1.0"))
        #expect(output.contains("  G: 0.1"))
        #expect(output.contains("  B: 1.0"))
        #expect(output.contains("  A: 0.0"))
    }

    @Test("formats JSON output with all fields")
    func jsonFormatting() throws {
        let result = ImageComparisonResult(mae: 2.1, red: 1.0, green: 0.1, blue: 1.0, alpha: 0.0)
        let output = try PeepCommand.formatJSON(result)

        #expect(output.contains("\"mae\""))
        #expect(output.contains("\"red\""))
        #expect(output.contains("\"green\""))
        #expect(output.contains("\"blue\""))
        #expect(output.contains("\"alpha\""))
    }
}
