import Darwin

@frozen
@dynamicMemberLookup
public struct SysctlNamespaceContainer<Namespace: SysctlNamespace> {
    @usableFromInline
    var namespace: Namespace

    @usableFromInline
    init(namespace: Namespace) {
        self.namespace = namespace
    }

    @usableFromInline
    func _read<Value: SysctlValue>(_ fieldPath: KeyPath<Namespace, Namespace.Field<Value>>) -> Value {
        Namespace._buildName(for: namespace[keyPath: fieldPath]).withCString {
            var size = Int()
            guard sysctlbyname($0, nil, &size, nil, 0) == 0 else { fatalError("sysctlbyname failed (\(errno))!") }
            let capacity = size / MemoryLayout<Value.SysctlPointerType>.size
            let pointer = UnsafeMutablePointer<Value.SysctlPointerType>.allocate(capacity: capacity)
            defer { pointer.deallocate() }
            guard sysctlbyname($0, pointer, &size, nil, 0) == 0 else { fatalError("sysctlbyname failed (\(errno))!") }
            return Value(sysctlPointer: pointer)
        }
    }

    @usableFromInline
    func _write<Value: SysctlValue>(_ value: Value, to fieldPath: WritableKeyPath<Namespace, Namespace.Field<Value>>) {
        Namespace._buildName(for: namespace[keyPath: fieldPath]).withCString { sysctlName in
            value.withSysctlPointer {
                guard sysctlbyname(sysctlName, nil, nil, UnsafeMutableRawPointer(mutating: $0), $1) == 0 else {
                    fatalError("sysctlbyname failed (\(errno))!")
                }
            }
        }
    }

    @inlinable
    public subscript<ChildSpace: SysctlNamespace>(dynamicMember childSpace: KeyPath<Namespace, ChildSpace>) -> SysctlNamespaceContainer<ChildSpace>
    where ChildSpace.ParentNamespace == Namespace
    {
        SysctlNamespaceContainer<ChildSpace>(namespace: namespace[keyPath: childSpace])
    }

    @inlinable
    public subscript<ChildSpace: SysctlNamespace>(dynamicMember childSpace: WritableKeyPath<Namespace, ChildSpace>) -> SysctlNamespaceContainer<ChildSpace>
    where ChildSpace.ParentNamespace == Namespace
    {
        get { SysctlNamespaceContainer<ChildSpace>(namespace: namespace[keyPath: childSpace]) }
        set { namespace[keyPath: childSpace] = newValue.namespace }
    }

    @inlinable
    public subscript<Value: SysctlValue>(dynamicMember field: KeyPath<Namespace, Namespace.Field<Value>>) -> Value {
        self._read(field)
    }

    @inlinable
    public subscript<Value: SysctlValue>(dynamicMember field: WritableKeyPath<Namespace, Namespace.Field<Value>>) -> Value {
        get { self._read(field) }
        nonmutating set { self._write(newValue, to: field) }
    }
}
