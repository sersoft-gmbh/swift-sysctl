/// Describes a sysctl field name inside a sysctl namespace.
/// For easier definition, use the `SysctlNamespace.Field` typealias.
/// Fields are `ExpressibleByStringLiteral`. Thus you can simply use `"yourfieldname"` to create fields.
@frozen
public struct SysctlNamedField<Parent: SysctlNamespace, Value: SysctlValue>: Hashable, ExpressibleByStringLiteral {
    /// See `ExpressibleByStringLiteral`.
    public typealias StringLiteralType = String

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
    public init(stringLiteral value: StringLiteralType) {
        self.init(namePart: value)
    }
}

extension SysctlNamespace {
    /// A field inside this namespace.
    public typealias Field<T: SysctlValue> = SysctlNamedField<Self, T>
}

#if compiler(>=5.5.2) && canImport(_Concurrency)
extension SysctlNamedField: Sendable where Value: Sendable {}
#endif
