#if swift(>=6.0)
fileprivate import Darwin
#else
public import Darwin
#endif

/// Namespace for the hardware part (`hw`).
public struct Hardware: SysctlFullyQualifiedNamespace {
    public typealias ParentNamespace = SysctlRootNamespace

    public static var namePart: String { "hw" }
    public static var managementInformationBasePart: CInt { CTL_HW }

    /// The machine value (`machine`).
    public var machine: Field<String> {
        .init(managementInformationBasePart: HW_MACHINE, namePart: "machine")
    }
    /// The model value (`model`).
    public var model: Field<String> {
        .init(managementInformationBasePart: HW_MODEL, namePart: "model")
    }

    /// The number of CPUs (`ncpu`).
    public var numberOfCPUs: Field<CInt> {
        .init(managementInformationBasePart: HW_NCPU, namePart: "ncpu")
    }
    /// The  number of physical CPUs (`physicalcpu`).
    public var physicalCPUs: Field<CInt> { "physicalcpu" }

    /// The memory size (`memsize`) in bytes.
    public var memorySize: Field<CLongLong> {
        .init(managementInformationBasePart: HW_MEMSIZE, namePart: "memsize")
    }
}

extension SysctlRootNamespace {
    /// The hardware (`hw`) part.
    public var hardware: Hardware { .init() }
}
