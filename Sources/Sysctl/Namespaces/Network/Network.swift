/// The namespace for the networking values (`net`).
public struct Networking: SysctlNamespace {
    /// See SysctlNamespace
    public typealias ParentNamespace = SysctlRootNamespace

    /// See SysctlNamespace
    public static var namePart: String { "net" }
}

extension SysctlRootNamespace {
    /// The networking (`net`) part.
    public var networking: Networking { .init() }
}
