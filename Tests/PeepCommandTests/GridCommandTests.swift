@testable import PeepCommand
import Testing

@Suite("GridCommand")
struct GridCommandTests {
    // MARK: - Argument parsing

    @Test("parses image path and required options")
    func parsesArguments() throws {
        let command = try PeepCommand.parseAsRoot([
            "grid", "photo.png",
            "--spacing", "10",
            "--output", "out.png",
        ])
        let grid = try #require(command as? GridCommand)

        #expect(grid.image == "photo.png")
        #expect(grid.spacing == 10)
        #expect(grid.output == "out.png")
    }

    @Test("parses --color option")
    func parsesColor() throws {
        let command = try PeepCommand.parseAsRoot([
            "grid", "a.png",
            "--spacing", "10",
            "--color", "#00ff00",
            "--output", "out.png",
        ])
        let grid = try #require(command as? GridCommand)

        #expect(grid.color == "#00ff00")
    }

    @Test("parses --scale option")
    func parsesScale() throws {
        let command = try PeepCommand.parseAsRoot([
            "grid", "a.png",
            "--spacing", "10",
            "--output", "out.png",
            "--scale", "3",
        ])
        let grid = try #require(command as? GridCommand)

        #expect(grid.scale == 3)
    }

    @Test("defaults color to #ff0000 and scale to 2")
    func defaults() throws {
        let command = try PeepCommand.parseAsRoot([
            "grid", "a.png",
            "--spacing", "10",
            "--output", "out.png",
        ])
        let grid = try #require(command as? GridCommand)

        #expect(grid.color == "#ff0000")
        #expect(grid.scale == 2)
    }
}
