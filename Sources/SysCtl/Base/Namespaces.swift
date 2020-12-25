/// Describes a namespace in the sysctl landscape.
/// Sysctl separates its values using dots (e.g. `net.inet.ip.forwarding`).
/// Each part (without the dots) is represented as a namespace (e.g. `net` -> `Networking`, `inet` -> `Networking.IPv4`, ...).
public protocol SysctlNamespace {
    /// The parent namespace for this namespace.
    /// Use `SysctlRootNamespace` if this namespace is located at the root of sysctl (e.g. `net`).
    associatedtype ParentNamespace: SysctlNamespace

    /// The name part of the namespace (e.g. `net` for `Networking`, or `hw` for `Hardware`).
    static var namePart: String { get }
}

extension SysctlNamespace {
    /// A field inside this namespace.
    public typealias Field<T: SysctlValue> = SysctlNamedField<Self, T>
}

/// The root namespace.
@frozen
public struct SysctlRootNamespace: SysctlNamespace {
    /// The parent of the root is always the root namespace.
    public typealias ParentNamespace = Self

    /// The root namespace has no name part. Do not call this.
    public static var namePart: String {
        assertionFailure("`namePart` accessed on `SysctlRootNamespace`!")
        return ""
    }

    @inlinable
    init() {}
}

/// Describes a sysctl field name inside a sysctl namespace.
/// For easier definition, use the `SysctlNamespace.Field` typealias.
/// Fields are `ExpressibleByStringLiteral`. Thus you can simply use `"yourfieldname"` to create fields.
@frozen
public struct SysctlNamedField<Parent: SysctlNamespace, Value: SysctlValue>: Hashable, ExpressibleByStringLiteral {
    /// The name part of the field.
    @usableFromInline
    let namePart: String

    /// Creates a new field with the given name part.
    /// - Parameter namePart: The name part.
    @usableFromInline
    init(namePart: String) {
        self.namePart = namePart
    }

    /// See `ExpressibleByStringLiteral.init(stringLiteral:)`.
    @inlinable
    public init(stringLiteral value: String) {
        self.init(namePart: value)
    }
}
