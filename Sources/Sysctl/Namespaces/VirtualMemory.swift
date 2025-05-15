public import Darwin

/// The virtual memory namespace (`vm`).
public struct VirtualMemory: SysctlFullyQualifiedNamespace {
    public typealias ParentNamespace = SysctlRootNamespace

    public static var namePart: String { "vm" }
    public static var managementInformationBasePart: CInt { CTL_VM }

    /// The load average history (`loadavg`).
    public var loadAverageHistory: Field<loadavg> {
        .init(managementInformationBasePart: VM_LOADAVG, namePart: "loadavg")
    }

    /// Wheter swapping is enabled (`swap_enabled`).
    public var isSwappingEnabled: Field<Bool> {
        get { "swap_enabled" }
        nonmutating set {}
    }
}

extension SysctlRootNamespace {
    /// The virtual memory values (`vm`).
    public var virtualMemory: VirtualMemory { .init() }
}
