/// Describes a namespace in the sysctl landscape.
/// Sysctl separates its values using dots (e.g. `net.inet.ip.forwarding`).
/// Each part (without the dots) is represented as a namespace (e.g. `net` -> ``Networking``, `inet` -> ``Networking/IPv4``, ...).
public protocol SysctlNamespace: Sendable {
    /// The parent namespace for this namespace.
    /// Use ``SysctlRootNamespace`` if this namespace is located at the root of sysctl (e.g. `net`).
    associatedtype ParentNamespace: SysctlNamespace

    /// The name part of the namespace (e.g. `net` for ``Networking``, or `hw` for ``Hardware``).
    static var namePart: String { get }

    /// The mib part of the namespace (e.g. `CTL_NET` for ``Networking``)
    static var managementInformationBasePart: CInt? { get }
}

extension SysctlNamespace {
    public static var managementInformationBasePart: CInt? { nil }
}

public protocol SysctlFullyQualifiedNamespace: SysctlNamespace
where ParentNamespace: SysctlFullyQualifiedNamespace
{
    /// The mib part of the namespace.
    static var managementInformationBasePart: CInt { get }
}

extension SysctlFullyQualifiedNamespace {
    @inlinable
    public static  var managementInformationBasePart: CInt? { managementInformationBasePart as CInt }
}

/// The root namespace.
@frozen
public struct SysctlRootNamespace: SysctlFullyQualifiedNamespace {
    /// The parent of the root is always the root namespace.
    public typealias ParentNamespace = Self

    /// The root namespace has no name part. Do not call this.
    public static var namePart: String {
        assertionFailure("`\(#function)` accessed on `\(Self.self)`!")
        return .init()
    }

    /// The root namespace has no mib part. Do not call this.
    public static var managementInformationBasePart: CInt {
        assertionFailure("`\(#function)` accessed on `\(Self.self)`!")
        return .init()
    }

    @inlinable
    init() {}
}
