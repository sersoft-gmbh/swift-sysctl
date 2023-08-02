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

    public init(managementInformationBasePart: CInt, namePart: String) {
        self.init(_mib: managementInformationBasePart, _name: namePart)
    }

    public init(managementInformationBasePart: CInt? = nil, namePart: String) {
        self.init(_mib: managementInformationBasePart, _name: namePart)
    }
}

extension SysctlField: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String

    @inlinable
    public init(stringLiteral value: String) {
        self.init(_mib: nil, _name: value)
    }
}

extension SysctlField where Namespace: SysctlFullyQualifiedNamespace {
    public init(managementInformationBasePart: CInt, namePart: String? = nil) {
        self.init(_mib: managementInformationBasePart, _name: namePart)
    }

    public init?(managementInformationBasePart: CInt?, namePart: String?) {
        guard managementInformationBasePart != nil || namePart != nil else { return nil }
        self.init(_mib: managementInformationBasePart, _name: namePart)
    }
}

extension SysctlField: ExpressibleByIntegerLiteral where Namespace: SysctlFullyQualifiedNamespace {
    public typealias IntegerLiteralType = CInt

    @inlinable
    public init(integerLiteral value: CInt) {
        self.init(_mib: value, _name: nil)
    }
}

extension SysctlNamespace {
    /// A field inside this namespace.
    public typealias Field<T: SysctlValue> = SysctlField<Self, T>
}

@available(*, deprecated, message: "Use SysctlField", renamed: "SysctlField")
public typealias SysctlNamedField = SysctlField

extension SysctlField {
    @available(*, deprecated, message: "Use Namespace", renamed: "Namespace")
    public typealias Parent = Namespace
}
