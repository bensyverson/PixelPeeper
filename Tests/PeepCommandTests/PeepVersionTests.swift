@testable import PeepCommand
import Testing

@Suite("PeepVersion")
struct PeepVersionTests {
    @Test
    func `--version prints the release version and exits cleanly`() throws {
        do {
            _ = try PeepCommand.parseAsRoot(["--version"])
            Issue.record("--version should exit before a command runs")
        } catch {
            #expect(PeepCommand.message(for: error) == PeepVersion.current)
            #expect(PeepCommand.exitCode(for: error) == .success)
        }
    }
}
