import ArgumentParser
@testable import PeepCommand
import Testing

@Suite("DiffCommand")
struct DiffCommandTests {
    // MARK: - Argument parsing

    @Test
    func `parses two positional image paths and required options`() throws {
        let command = try PeepCommand.parseAsRoot([
            "diff", "a.png", "b.png",
            "--output", "out.png",
        ])
        let diff = try #require(command as? DiffCommand)

        #expect(diff.image1 == "a.png")
        #expect(diff.image2 == "b.png")
        #expect(diff.output == "out.png")
    }

    @Test
    func `parses --intensity option`() throws {
        let command = try PeepCommand.parseAsRoot([
            "diff", "a.png", "b.png",
            "--output", "out.png",
            "--intensity", "2.5",
        ])
        let diff = try #require(command as? DiffCommand)

        #expect(diff.intensity == 2.5)
    }

    @Test
    func `parses --resize flag`() throws {
        let command = try PeepCommand.parseAsRoot([
            "diff", "a.png", "b.png",
            "--output", "out.png",
            "--resize",
        ])
        let diff = try #require(command as? DiffCommand)

        #expect(diff.resize == true)
    }

    @Test
    func `parses --scale option`() throws {
        let command = try PeepCommand.parseAsRoot([
            "diff", "a.png", "b.png",
            "--output", "out.png",
            "--scale", "3",
        ])
        let diff = try #require(command as? DiffCommand)

        #expect(diff.scale == 3)
    }

    @Test
    func `defaults intensity to 1.0, resize to false, scale to 2`() throws {
        let command = try PeepCommand.parseAsRoot([
            "diff", "a.png", "b.png",
            "--output", "out.png",
        ])
        let diff = try #require(command as? DiffCommand)

        #expect(diff.intensity == 1.0)
        #expect(diff.resize == false)
        #expect(diff.scale == 2)
    }

    // MARK: - Validation

    @Test
    func `rejects zero intensity`() throws {
        // parseAsRoot calls validate() automatically, so we expect the whole parse to throw
        #expect(throws: (any Error).self) {
            try PeepCommand.parseAsRoot([
                "diff", "a.png", "b.png",
                "--output", "out.png",
                "--intensity", "0",
            ])
        }
    }

    @Test
    func `rejects negative intensity via validate()`() throws {
        // Construct directly to test validate() with negative value
        var diff = DiffCommand()
        diff.image1 = "a.png"
        diff.image2 = "b.png"
        diff.output = "out.png"
        diff.intensity = -1.0

        #expect(throws: ValidationError.self) {
            try diff.validate()
        }
    }
}
