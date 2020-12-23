@frozen
@dynamicMemberLookup
public struct SystemControl {
    @usableFromInline
    var container = SysctlNamespaceContainer<SysctlRootNamespace>(namespace: .init())

    public init() {}

    @inlinable
    public subscript<ChildSpace: SysctlNamespace>(dynamicMember childSpace: KeyPath<SysctlRootNamespace, ChildSpace>) -> SysctlNamespaceContainer<ChildSpace>
    where ChildSpace.ParentNamespace == SysctlRootNamespace
    {
        container[dynamicMember: childSpace]
    }

    @inlinable
    public subscript<ChildSpace: SysctlNamespace>(dynamicMember childSpace: WritableKeyPath<SysctlRootNamespace, ChildSpace>) -> SysctlNamespaceContainer<ChildSpace>
    where ChildSpace.ParentNamespace == SysctlRootNamespace
    {
        get { container[dynamicMember: childSpace] }
        set { container[dynamicMember: childSpace] = newValue }
    }

    @inlinable
    public subscript<Value: SysctlValue>(dynamicMember field: KeyPath<SysctlRootNamespace, SysctlRootNamespace.Field<Value>>) -> Value {
        container[dynamicMember: field]
    }

    @inlinable
    public subscript<Value: SysctlValue>(dynamicMember field: WritableKeyPath<SysctlRootNamespace, SysctlRootNamespace.Field<Value>>) -> Value {
        get { container[dynamicMember: field] }
        nonmutating set { container[dynamicMember: field] = newValue }
    }
}
