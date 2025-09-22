/// Describes a field inside a sysctl namespace.
/// For easier definition, use the ``SysctlNamespace/Field`` typealias.
/// Fields are ``Swift/ExpressibleByStringLiteral``. Thus you can simply use `"yourfieldname"` to create fields.
/// If the `Namespace` conforms to ``SysctlFullyQualifiedNamespace``, the field can also be expressed by an integer literal.
@frozen
public struct SysctlField<Namespace: SysctlNamespace, Value: SysctlValue>: Sendable, Hashable {
    /// The mib part of the field.
    @usableFromInline
    let mibPart: CInt?
    /// The name part of the field.
    @usableFromInline
    let namePart: String?

    @usableFromInline
    init(_mib: CInt?, _name: String?) {
        precondition(_mib != nil || _name != nil)
        mibPart = _mib
        namePart = _name
    }

#if compiler(>=6.2)
    /// Creates a new field with the given mib and name parts.
    /// - Parameters:
    ///  - managementInformationBasePart: The management information base (MIB) part of the field.
    ///  - namePart: The name part of the field.
    @safe
    @inlinable
    public init(managementInformationBasePart: CInt, namePart: String) {
        self.init(_mib: managementInformationBasePart, _name: namePart)
    }

    /// Creates a new field with the given mib and name parts.
    /// - Parameters:
    ///  - managementInformationBasePart: The management information base (MIB) part of the field.
    ///  - namePart: The name part of the field.
    @safe
    @inlinable
    public init(managementInformationBasePart: CInt? = nil, namePart: String) {
        self.init(_mib: managementInformationBasePart, _name: namePart)
    }
#else
    /// Creates a new field with the given mib and name parts.
    /// - Parameters:
    ///  - managementInformationBasePart: The management information base (MIB) part of the field.
    ///  - namePart: The name part of the field.
    @inlinable
    public init(managementInformationBasePart: CInt, namePart: String) {
        self.init(_mib: managementInformationBasePart, _name: namePart)
    }

    /// Creates a new field with the given mib and name parts.
    /// - Parameters:
    ///  - managementInformationBasePart: The management information base (MIB) part of the field.
    ///  - namePart: The name part of the field.
    @inlinable
    public init(managementInformationBasePart: CInt? = nil, namePart: String) {
        self.init(_mib: managementInformationBasePart, _name: namePart)
    }
#endif
}

extension SysctlField: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String

#if compiler(>=6.2)
    @safe
    @inlinable
    public init(stringLiteral value: String) {
        self.init(_mib: nil, _name: value)
    }
#else
    @inlinable
    public init(stringLiteral value: String) {
        self.init(_mib: nil, _name: value)
    }
#endif
}

extension SysctlField where Namespace: SysctlFullyQualifiedNamespace {
#if compiler(>=6.2)
    /// Creates a new field with the given mib and name parts.
    /// - Parameters:
    ///  - managementInformationBasePart: The management information base (MIB) part of the field.
    ///  - namePart: The name part of the field.
    @safe
    @inlinable
    public init(managementInformationBasePart: CInt, namePart: String? = nil) {
        self.init(_mib: managementInformationBasePart, _name: namePart)
    }

    /// Creates a new field with the given mib and name parts. Returns nil if both parameters are nil.
    /// - Parameters:
    ///  - managementInformationBasePart: The management information base (MIB) part of the field.
    ///  - namePart: The name part of the field.
    @safe
    @inlinable
    public init?(managementInformationBasePart: CInt?, namePart: String?) {
        guard managementInformationBasePart != nil || namePart != nil else { return nil }
        self.init(_mib: managementInformationBasePart, _name: namePart)
    }
#else
    /// Creates a new field with the given mib and name parts.
    /// - Parameters:
    ///  - managementInformationBasePart: The management information base (MIB) part of the field.
    ///  - namePart: The name part of the field.
    @inlinable
    public init(managementInformationBasePart: CInt, namePart: String? = nil) {
        self.init(_mib: managementInformationBasePart, _name: namePart)
    }

    /// Creates a new field with the given mib and name parts. Returns nil if both parameters are nil.
    /// - Parameters:
    ///  - managementInformationBasePart: The management information base (MIB) part of the field.
    ///  - namePart: The name part of the field.
    @inlinable
    public init?(managementInformationBasePart: CInt?, namePart: String?) {
        guard managementInformationBasePart != nil || namePart != nil else { return nil }
        self.init(_mib: managementInformationBasePart, _name: namePart)
    }
#endif
}

extension SysctlField: ExpressibleByIntegerLiteral where Namespace: SysctlFullyQualifiedNamespace {
    public typealias IntegerLiteralType = CInt

#if compiler(>=6.2)
    @safe
    @inlinable
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(_mib: value, _name: nil)
    }
#else
    @inlinable
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(_mib: value, _name: nil)
    }
#endif
}

extension SysctlNamespace {
    /// A field inside this namespace.
    public typealias Field<Value: SysctlValue> = SysctlField<Self, Value>
}

@available(*, deprecated, message: "Use SysctlField", renamed: "SysctlField")
public typealias SysctlNamedField = SysctlField

extension SysctlField {
    @available(*, deprecated, message: "Use Namespace", renamed: "Namespace")
    public typealias Parent = Namespace
}
