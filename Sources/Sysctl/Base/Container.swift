import Darwin

extension SysctlNamespace {
    @usableFromInline
    static var _isRoot: Bool { self == SysctlRootNamespace.self }

    @inlinable
    static func _mibParts() -> Array<CInt>? {
        guard !_isRoot else { return .init() }
        guard let parent = ParentNamespace._mibParts(),
              let mibPart = managementInformationBasePart
        else { return nil }
        return parent + CollectionOfOne(mibPart)
    }

    @inlinable
    static func _nameParts() -> Array<String> {
        _isRoot ? .init() : ParentNamespace._nameParts() + CollectionOfOne(namePart)
    }
}

extension SysctlFullyQualifiedNamespace {
    @inlinable
    static func _mibParts() -> Array<CInt> {
        _isRoot ? .init() : ParentNamespace._mibParts() + CollectionOfOne(managementInformationBasePart)
    }
}

extension SysctlField {
    @inlinable
    func _buildMib() -> Array<CInt>? {
#if swift(>=5.7)
        guard let mibPart, let parts = Namespace._mibParts() else { return nil }
#else
        guard let mibPart = mibPart, let parts = Namespace._mibParts() else { return nil }
#endif
        return parts + CollectionOfOne(mibPart)
    }

    @inlinable
    func _buildName() -> String? {
#if swift(>=5.7)
        guard let namePart else { return nil }
#else
        guard let namePart = namePart else { return nil }
#endif
        return (Namespace._nameParts() + CollectionOfOne(namePart)).joined(separator: ".")
    }

    private static func _mib(forName name: String) -> Array<CInt> {
        name.withCString {
            var len = Int()
            _sysctlNameToMIB($0, nil, &len).requireSuccess()
            let mib = UnsafeMutablePointer<CInt>.allocate(capacity: len)
            defer { mib.deallocate() }
            _sysctlNameToMIB($0, mib, &len).requireSuccess()
            return .init(unsafeUninitializedCapacity: len) { buffer, initializedCount in
#if swift(>=5.8)
                buffer.baseAddress?.moveUpdate(from: mib, count: len)
#else
                buffer.baseAddress?.moveAssign(from: mib, count: len)
#endif
                initializedCount = len
            }
        }
    }

    @usableFromInline
    func _withMIB<T>(do work: (inout UnsafeMutableBufferPointer<CInt>) throws -> T) rethrows -> T {
        guard var mib = _buildMib() ?? _buildName().map(Self._mib(forName:))
        else { fatalError("Invalid field: \(self)") }
        return try mib.withUnsafeMutableBufferPointer(work)
    }
}

/// A container that gives access to the children namespaces and values of a ``SysctlNamespace``.
@frozen
@dynamicMemberLookup
public struct SysctlContainer<Namespace: SysctlNamespace>: Sendable {
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

    @usableFromInline
    func _readValue<Value: SysctlValue>(for fieldPath: KeyPath<Namespace, Namespace.Field<Value>>) -> Value {
        namespace[keyPath: fieldPath]._withMIB {
            var size = Int()
            _sysctl($0.baseAddress!, numericCast($0.count), nil, &size, nil, 0).requireSuccess()
            let capacity = size / MemoryLayout<Value.SysctlPointerType>.size
            let pointer = UnsafeMutablePointer<Value.SysctlPointerType>.allocate(capacity: capacity)
            defer { pointer.deallocate() }
            _sysctl($0.baseAddress!, numericCast($0.count), pointer, &size, nil, 0).requireSuccess()
            return Value(sysctlPointer: pointer, capacity: capacity)
        }
    }

    @usableFromInline
    func _writeValue<Value: SysctlValue>(_ value: Value, to fieldPath: WritableKeyPath<Namespace, Namespace.Field<Value>>) {
        namespace[keyPath: fieldPath]._withMIB { mib in
            value.withSysctlPointer {
                _sysctl(mib.baseAddress!, numericCast(mib.count), nil, nil, UnsafeMutableRawPointer(mutating: $0), $1).requireSuccess()
            }
        }
    }
}
