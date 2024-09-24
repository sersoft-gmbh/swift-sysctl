#if swift(>=6.0)
fileprivate import Darwin
#else
public import Darwin
#endif

/// The namespace for the machine dependent values (`machdep`).
public struct MachineDependent: SysctlFullyQualifiedNamespace {
    public typealias ParentNamespace = SysctlRootNamespace

    public static var namePart: String { "machdep" }
    public static var managementInformationBasePart: CInt { CTL_MACHDEP }
}

extension MachineDependent {
    /// The namespace for CPU  (`cpu`) values inside the machine dependent namespace.
    public struct CPU: SysctlNamespace {
        public typealias ParentNamespace = MachineDependent

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
