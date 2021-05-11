import Darwin

extension SysctlNamespace {
    @usableFromInline
    static var _isRoot: Bool { self == SysctlRootNamespace.self }

    @inlinable
    static func _nameParts() -> [String] {
        _isRoot ? [] : ParentNamespace._nameParts() + CollectionOfOne(namePart)
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

    /// Runs `sysctlbyname` trapping on failures.
    /// Signature is copied from `sysctlbyname` except for the `file` and `line` parameters.
    private func _runSysctl(_ name: UnsafePointer<CChar>!,
                            _ oldptr: UnsafeMutableRawPointer!,
                            _ oldlenptr: UnsafeMutablePointer<Int>!,
                            _ newptr: UnsafeMutableRawPointer!,
                            _ newlen: Int,
                            file: StaticString = #file,
                            line: UInt = #line) {
        guard sysctlbyname(name, oldptr, oldlenptr, newptr, newlen) != 0 else { return }
        defer { errno = 0 } // Reset for unsafe builds that don't trap.
        fatalError("sysctlbyname failed when \(newptr != nil ? "writing" : "reading") '\(String(cString: name))' (\(errno))!",
                   file: file, line: line)
    }

    @usableFromInline
    func _readValue<Value: SysctlValue>(for fieldPath: KeyPath<Namespace, Namespace.Field<Value>>) -> Value {
        _withName(for: fieldPath) {
            var size = Int()
            _runSysctl($0, nil, &size, nil, 0)
            let capacity = size / MemoryLayout<Value.SysctlPointerType>.size
            let pointer = UnsafeMutablePointer<Value.SysctlPointerType>.allocate(capacity: capacity)
            defer { pointer.deallocate() }
            _runSysctl($0, pointer, &size, nil, 0)
            return Value(sysctlPointer: pointer)
        }
    }

    @usableFromInline
    func _writeValue<Value: SysctlValue>(_ value: Value, to fieldPath: WritableKeyPath<Namespace, Namespace.Field<Value>>) {
        _withName(for: fieldPath) { sysctlName in
            value.withSysctlPointer {
                _runSysctl(sysctlName, nil, nil, UnsafeMutableRawPointer(mutating: $0), $1)
            }
        }
    }
}
