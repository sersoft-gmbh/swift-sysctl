#if compiler(>=5.5.2) && canImport(_Concurrency)
/// The base for `SysctlNamespace`. This is an implementation detail and should not be used directly.
public typealias _SysctlNamespaceBase = Sendable
#else
/// The base for `SysctlNamespace`. This is an implementation detail and should not be used directly.
public protocol _SysctlNamespaceBase {}
#endif

/// Describes a namespace in the sysctl landscape.
/// Sysctl separates its values using dots (e.g. `net.inet.ip.forwarding`).
/// Each part (without the dots) is represented as a namespace (e.g. `net` -> `Networking`, `inet` -> `Networking.IPv4`, ...).
public protocol SysctlNamespace: _SysctlNamespaceBase {
    /// The parent namespace for this namespace.
    /// Use `SysctlRootNamespace` if this namespace is located at the root of sysctl (e.g. `net`).
    associatedtype ParentNamespace: SysctlNamespace

    /// The name part of the namespace (e.g. `net` for `Networking`, or `hw` for `Hardware`).
    static var namePart: String { get }
}

/// The root namespace.
@frozen
public struct SysctlRootNamespace: SysctlNamespace {
    /// The parent of the root is always the root namespace.
    public typealias ParentNamespace = Self

    /// The root namespace has no name part. Do not call this.
    public static var namePart: String {
        assertionFailure("`\(#function)` accessed on `\(Self.self)`!")
        return ""
    }

    @inlinable
    init() {}
}
