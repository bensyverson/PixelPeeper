/// A convenience protocol composition requiring types to be codable, equatable, hashable, and sendable.
///
/// Conforming to `Friendly` ensures types can be serialized, compared, used as dictionary keys,
/// and safely shared across concurrency boundaries.
public typealias Friendly = Codable & Equatable & Hashable & Sendable
