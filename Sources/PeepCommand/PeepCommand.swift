import ArgumentParser

/// Root command for the peep CLI, providing image comparison and pixel sampling subcommands.
@main
struct PeepCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "peep",
        abstract: "Image comparison and pixel sampling tools.",
        subcommands: [CompareCommand.self, SampleCommand.self]
    )
}
