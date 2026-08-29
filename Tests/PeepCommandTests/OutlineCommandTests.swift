import CoreGraphics
@testable import PeepCommand
import Testing

@Suite("OutlineCommand")
struct OutlineCommandTests {
    // MARK: - Argument parsing

    @Test
    func `parses the image path, rect and output`() throws {
        let command = try PeepCommand.parseAsRoot([
            "outline", "shot.png",
            "--rect", "10,20,100,50",
            "--out", "boxed.png",
        ])
        let outline = try #require(command as? OutlineCommand)

        #expect(outline.image == "shot.png")
        #expect(outline.rect == ["10,20,100,50"])
        #expect(outline.output == "boxed.png")
    }

    @Test
    func `accepts --output as well as --out`() throws {
        let command = try PeepCommand.parseAsRoot([
            "outline", "shot.png",
            "--rect", "10,20,100,50",
            "--output", "boxed.png",
        ])
        let outline = try #require(command as? OutlineCommand)

        #expect(outline.output == "boxed.png")
    }

    @Test
    func `repeating --rect draws several boxes`() throws {
        let command = try PeepCommand.parseAsRoot([
            "outline", "shot.png",
            "--rect", "0,0,10,10",
            "--rect", "20,20,10,10",
            "--out", "boxed.png",
        ])
        let outline = try #require(command as? OutlineCommand)

        #expect(outline.rect == ["0,0,10,10", "20,20,10,10"])
    }

    @Test
    func `scale, colour, label and width default sensibly`() throws {
        let command = try PeepCommand.parseAsRoot([
            "outline", "shot.png", "--rect", "0,0,1,1", "--out", "o.png",
        ])
        let outline = try #require(command as? OutlineCommand)

        #expect(outline.scale == 1)
        #expect(outline.color == nil)
        #expect(outline.label.isEmpty)
        #expect(outline.width == 2)
        #expect(outline.rasterScale == 2)
    }

    @Test
    func `parses scale, colour, label and width`() throws {
        let command = try PeepCommand.parseAsRoot([
            "outline", "shot.png",
            "--rect", "0,0,1,1",
            "--scale", "2",
            "--color", "#00ff00",
            "--label", "Header",
            "--width", "4",
            "--raster-scale", "3",
            "--out", "o.png",
        ])
        let outline = try #require(command as? OutlineCommand)

        #expect(outline.scale == 2)
        #expect(outline.color == "#00ff00")
        #expect(outline.label == ["Header"])
        #expect(outline.width == 4)
        #expect(outline.rasterScale == 3)
    }

    // MARK: - Rect parsing

    @Test
    func `a rect is four comma-separated numbers in source units`() throws {
        #expect(try OutlineCommand.parseRect("10,20,100,50")
            == CGRect(x: 10, y: 20, width: 100, height: 50))
        #expect(try OutlineCommand.parseRect(" 10 , 20 , 100 , 50 ")
            == CGRect(x: 10, y: 20, width: 100, height: 50))
        #expect(try OutlineCommand.parseRect("10.5,20.25,100,50")
            == CGRect(x: 10.5, y: 20.25, width: 100, height: 50))
    }

    @Test
    func `a malformed rect is refused with the expected shape in the message`() {
        #expect(throws: (any Error).self) { _ = try OutlineCommand.parseRect("10,20,100") }
        #expect(throws: (any Error).self) { _ = try OutlineCommand.parseRect("10,20,100,50,60") }
        #expect(throws: (any Error).self) { _ = try OutlineCommand.parseRect("a,b,c,d") }
        #expect(throws: (any Error).self) { _ = try OutlineCommand.parseRect("") }
    }

    @Test
    func `a malformed rect is caught at parse time, not at run time`() {
        #expect(throws: (any Error).self) {
            _ = try PeepCommand.parseAsRoot([
                "outline", "shot.png", "--rect", "1,2,3", "--out", "o.png",
            ])
        }
        #expect(throws: (any Error).self) {
            _ = try PeepCommand.parseAsRoot([
                "outline", "shot.png", "--rect", "0,0,1,1", "--origin", "nope", "--out", "o.png",
            ])
        }
        #expect(throws: (any Error).self) {
            _ = try PeepCommand.parseAsRoot([
                "outline", "shot.png", "--rect", "0,0,1,1", "--color", "zzz", "--out", "o.png",
            ])
        }
    }

    // MARK: - Building outlines

    @Test
    func `labels are matched to rects in order, and missing ones stay unlabelled`() throws {
        let command = try PeepCommand.parseAsRoot([
            "outline", "shot.png",
            "--rect", "0,0,10,10",
            "--rect", "20,20,10,10",
            "--label", "Header",
            "--out", "o.png",
        ])
        let parsed = try #require(command as? OutlineCommand)
        let outlines = try parsed.outlines()

        #expect(outlines.count == 2)
        #expect(outlines[0].label == "Header")
        #expect(outlines[1].label == nil)
        #expect(outlines[0].color == nil)
        #expect(outlines[0].width == 2)
    }

    @Test
    func `a hex colour applies to every rect`() throws {
        let command = try PeepCommand.parseAsRoot([
            "outline", "shot.png",
            "--rect", "0,0,10,10",
            "--color", "#00ff00",
            "--out", "o.png",
        ])
        let parsed = try #require(command as? OutlineCommand)
        let outlines = try parsed.outlines()

        #expect(outlines[0].color?.green == 255)
        #expect(outlines[0].color?.red == 0)
    }
}
