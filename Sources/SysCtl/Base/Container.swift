import Darwin

extension SysctlNamespace {
    @usableFromInline
    static func _nameParts() -> [String] {
        guard self != SysctlRootNamespace.self else { return [] }
        return ParentNamespace._nameParts() + CollectionOfOne(namePart)
    }

    @inlinable
    static func _buildName<T>(for field: Field<T>) -> String {
        (_nameParts() + CollectionOfOne(field.namePart)).joined(separator: ".")
    }
}

/// A container that gives access to the children namespaces and values of a `SysctlNamespace`.
@frozen
@dynamicMemberLookup
public struct SysctlContainer<Namespace: SysctlNamespace> {
    /// The namespace of the container.
    @usableFromInline
    let namespace: Namespace

    /// Creates a new container with the given namespace.
    /// - Parameter namespace: The namespace of the new container.
    @usableFromInline
    init(namespace: Namespace) {
        self.namespace = namespace
    }

    /// Returns a child container for the given child namespace path.
    /// - Parameter childSpace: The keypath to the child namespace.
    @inlinable
    public subscript<ChildSpace: SysctlNamespace>(dynamicMember childSpace: KeyPath<Namespace, ChildSpace>) -> SysctlContainer<ChildSpace>
    where ChildSpace.ParentNamespace == Namespace
    {
        SysctlContainer<ChildSpace>(namespace: namespace[keyPath: childSpace])
    }

    /// Reads the value for a field on the namespace.
    /// - Parameter field: The keypath to the field of the namespace.
    @inlinable
    public subscript<Value: SysctlValue>(dynamicMember field: KeyPath<Namespace, Namespace.Field<Value>>) -> Value {
        _readValue(for: field)
    }

    /// Reads or writes the value for a field on the namespace.
    /// - Parameter field: The keypath to the field of the namespace.
    @inlinable
    public subscript<Value: SysctlValue>(dynamicMember field: WritableKeyPath<Namespace, Namespace.Field<Value>>) -> Value {
        get { _readValue(for: field) }
        nonmutating set { _writeValue(newValue, to: field) }
    }
    
    @inlinable
    func _withName<T, Value: SysctlValue>(for fieldPath: KeyPath<Namespace, Namespace.Field<Value>>,
                                         do work: (UnsafePointer<CChar>) throws -> T) rethrows -> T {
        try Namespace._buildName(for: namespace[keyPath: fieldPath]).withCString(work)
    }

    @usableFromInline
    func _readValue<Value: SysctlValue>(for fieldPath: KeyPath<Namespace, Namespace.Field<Value>>) -> Value {
        _withName(for: fieldPath) {
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
    func _writeValue<Value: SysctlValue>(_ value: Value, to fieldPath: WritableKeyPath<Namespace, Namespace.Field<Value>>) {
        _withName(for: fieldPath) { sysctlName in
            value.withSysctlPointer {
                guard sysctlbyname(sysctlName, nil, nil, UnsafeMutableRawPointer(mutating: $0), $1) == 0 else {
                    fatalError("sysctlbyname failed (\(errno))!")
                }
            }
        }
    }
}
