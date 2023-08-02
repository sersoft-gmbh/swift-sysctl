import Darwin

/// The namespace for the networking values (`net`).
public struct Networking: SysctlFullyQualifiedNamespace {
    public typealias ParentNamespace = SysctlRootNamespace

    public static var namePart: String { "net" }
    public static var managementInformationBasePart: CInt { CTL_NET }
}

extension SysctlRootNamespace {
    /// The networking (`net`) part.
    public var networking: Networking { .init() }
}
