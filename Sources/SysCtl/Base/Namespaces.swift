public protocol SysctlNamespace {
    associatedtype ParentNamespace: SysctlNamespace

    static var sysctlNamePart: String { get }
}

@frozen
public struct SysctlRootNamespace: SysctlNamespace {
    public typealias ParentNamespace = Self

    public static var sysctlNamePart: String { "" }

    @inlinable
    init() {}
}

extension SysctlNamespace {
    public typealias Field<T: SysctlValue> = SysctlNamedField<Self, T>
}

extension SysctlNamespace {
    @usableFromInline
    static func _nameParts() -> [String] {
        guard self != SysctlRootNamespace.self else { return [] }
        return ParentNamespace._nameParts() + CollectionOfOne(sysctlNamePart)
    }
    @inlinable
    static func _nameParts() -> [String] where Self == SysctlRootNamespace { [] }

    @usableFromInline
    static func _buildName<T>(for field: Field<T>) -> String {
        (_nameParts() + CollectionOfOne(field.namePart)).joined(separator: ".")
    }
}

@frozen
public struct SysctlNamedField<Parent: SysctlNamespace, Value: SysctlValue>: Hashable, ExpressibleByStringLiteral {
    public let namePart: String

    public init(namePart: String) {
        self.namePart = namePart
    }

    @inlinable
    public init(stringLiteral value: String) {
        self.init(namePart: value)
    }
}
