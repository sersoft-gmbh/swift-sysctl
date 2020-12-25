/// The top level object to use for retrieving containers and values from sysctl.
/// It gives access to children namespaces and values of `SysctlRootNamespace`.
@frozen
@dynamicMemberLookup
public struct SystemControl {
    @usableFromInline
    let container = SysctlContainer<SysctlRootNamespace>(namespace: .init())

    /// Creates a new instance. Trivial to call.
    public init() {}

    /// Returns a child container for the given child namespace path.
    /// - Parameter childSpace: The keypath to the child namespace.
    @inlinable
    public subscript<ChildSpace: SysctlNamespace>(dynamicMember childSpace: KeyPath<SysctlRootNamespace, ChildSpace>) -> SysctlContainer<ChildSpace>
    where ChildSpace.ParentNamespace == SysctlRootNamespace
    {
        container[dynamicMember: childSpace]
    }

    /// Reads the value for a field on the root namespace.
    /// - Parameter field: The keypath to the field of the root namespace.
    @inlinable
    public subscript<Value: SysctlValue>(dynamicMember field: KeyPath<SysctlRootNamespace, SysctlRootNamespace.Field<Value>>) -> Value {
        container[dynamicMember: field]
    }

    /// Reads or writes the value for a field on the root namespace.
    /// - Parameter field: The keypath to the field of the root namespace.
    @inlinable
    public subscript<Value: SysctlValue>(dynamicMember field: WritableKeyPath<SysctlRootNamespace, SysctlRootNamespace.Field<Value>>) -> Value {
        get { container[dynamicMember: field] }
        nonmutating set { container[dynamicMember: field] = newValue }
    }
}
