import Darwin

public struct User: SysctlFullyQualifiedNamespace {
    public typealias ParentNamespace = SysctlRootNamespace

    public static var namePart: String { "user" }
    public static var managementInformationBasePart: CInt { CTL_USER }

    public var standardSearchPath: Field<String> {
        get { .init(managementInformationBasePart: USER_CS_PATH, namePart: "cs_path") }
        nonmutating set {}
    }
}

extension SysctlRootNamespace {
    /// The user values (`user`).
    public var user: User { .init() }
}
