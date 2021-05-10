/// Machdep (`machdep`) namespace for Sysctl
public struct Machdep: SysctlNamespace {
    /// See SysctlNamespace
    public typealias ParentNamespace = SysctlRootNamespace

    /// See SysctlNamespace
    public static var namePart: String { "machdep" }
}

public extension Machdep {
    /// The namespace for CPU  (`cpu`) values inside the machdep namespace.
    struct CPU: SysctlNamespace {
        /// See SysctlNamespace
        public typealias ParentNamespace = Machdep

        /// See SysctlNamespace
        public static var namePart: String { "cpu" }

        /// The kind of cpu (`brand_string`).
        public var brandString: Field<String> { "brand_string" }
    }
    
    var cpu: CPU { .init() }
}

extension SysctlRootNamespace {
    /// The macdep (`machdep`) part.
    public var machdep: Machdep { .init() }
}
