@testable import PeepCommand
import Testing

@Suite("CropCommand")
struct CropCommandTests {
    // MARK: - Argument parsing

    @Test("parses image path and required options")
    func parsesArguments() throws {
        let command = try PeepCommand.parseAsRoot([
            "crop", "photo.png",
            "--x", "10", "--y", "20",
            "--width", "100", "--height", "50",
            "--output", "out.png",
        ])
        let crop = try #require(command as? CropCommand)

        #expect(crop.image == "photo.png")
        #expect(crop.x == 10)
        #expect(crop.y == 20)
        #expect(crop.width == 100)
        #expect(crop.height == 50)
        #expect(crop.output == "out.png")
    }

    @Test("parses --inset option")
    func parsesInset() throws {
        let command = try PeepCommand.parseAsRoot([
            "crop", "a.png",
            "--x", "0", "--y", "0",
            "--width", "100", "--height", "100",
            "--inset", "5",
            "--output", "out.png",
        ])
        let crop = try #require(command as? CropCommand)

        #expect(crop.inset == 5)
    }

    @Test("parses --scale option")
    func parsesScale() throws {
        let command = try PeepCommand.parseAsRoot([
            "crop", "a.png",
            "--x", "0", "--y", "0",
            "--width", "10", "--height", "10",
            "--output", "out.png",
            "--scale", "3",
        ])
        let crop = try #require(command as? CropCommand)

        #expect(crop.scale == 3)
    }

    @Test("defaults inset to 0 and scale to 2")
    func defaults() throws {
        let command = try PeepCommand.parseAsRoot([
            "crop", "a.png",
            "--x", "0", "--y", "0",
            "--width", "10", "--height", "10",
            "--output", "out.png",
        ])
        let crop = try #require(command as? CropCommand)

        #expect(crop.inset == 0)
        #expect(crop.scale == 2)
    }
}
