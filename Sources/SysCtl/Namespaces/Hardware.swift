public struct Hardware: SysctlNamespace {
    public typealias ParentNamespace = SysctlRootNamespace

    public static var sysctlNamePart: String { "hw" }

    public var machine: Field<String> { "machine" }
    public var model: Field<String> { "model" }
}

extension SysctlRootNamespace {
    public var hardware: Hardware { .init() }
}
