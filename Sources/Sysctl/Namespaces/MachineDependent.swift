/// The namespace for the machine dependent values (`machdep`).
public struct MachineDependent: SysctlNamespace {
    /// See SysctlNamespace
    public typealias ParentNamespace = SysctlRootNamespace

    /// See SysctlNamespace
    public static var namePart: String { "machdep" }
}

extension MachineDependent {
    /// The namespace for CPU  (`cpu`) values inside the machine dependent namespace.
    public struct CPU: SysctlNamespace {
        /// See SysctlNamespace
        public typealias ParentNamespace = MachineDependent

        /// See SysctlNamespace
        public static var namePart: String { "cpu" }

        /// The cpu brand (`brand_string`).
        public var brandString: Field<String> { "brand_string" }
    }

    /// The cpu values (`cpu`).
    public var cpu: CPU { .init() }
}

extension SysctlRootNamespace {
    /// The machine dependent values (`machdep`).
    public var machineDependent: MachineDependent { .init() }
}
