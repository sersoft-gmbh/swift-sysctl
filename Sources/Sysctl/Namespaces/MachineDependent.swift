/// MachineDependent (`machdep`) namespace for Sysctl
public struct MachineDependent: SysctlNamespace {
    /// See SysctlNamespace
    public typealias ParentNamespace = SysctlRootNamespace

    /// See SysctlNamespace
    public static var namePart: String { "machdep" }
}

extension MachineDependent {
    /// The namespace for CPU  (`cpu`) values inside the machdep namespace.
    public struct CPU: SysctlNamespace {
        /// See SysctlNamespace
        public typealias ParentNamespace = MachineDependent

        /// See SysctlNamespace
        public static var namePart: String { "cpu" }

        /// The kind of cpu (`brand_string`).
        public var brandString: Field<String> { "brand_string" }
    }
    
    public var cpu: CPU { .init() }
}

extension SysctlRootNamespace {
    /// The MachineDependent (`machdep`) part.
    public var machineDependent: MachineDependent { .init() }
}
