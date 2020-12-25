import struct Foundation.Date

/// The namespace for the kernel values (`kern`).
public struct Kernel: SysctlNamespace {
    /// See SysctlNamespace
    public typealias ParentNamespace = SysctlRootNamespace

    /// See SysctlNamespace
    public static var namePart: String { "kern" }

    /// The kind of kernel (`ostype`).
    public var kind: Field<String> { "ostype" }
    /// The version of the kernel (`osrelease`).
    public var version: Field<String> { "osrelease" }
    /// The revision of the kernel (`osrevision`).
    public var revision: Field<String> { "osrevision" }
    /// The full version text of the kernel (`version`).
    public var fullVersionText: Field<String> { "version" }

    /// The OS build number (`osversion`).
    public var osBuild: Field<String> { "osversion" }

    /// The host ID (`hostid`).
    public var hostID: Field<CInt> {
        get { "hostid" }
        nonmutating set {}
    }
    /// The hostname (`hostname`).
    public var hostname: Field<String> {
        get { "hostname" }
        nonmutating set {}
    }

    /// The boot time (`boottime`).
    public var bootDate: Field<Date> { "boottime" }

    /// Whether or not the system runs in single user mode (`singleuser`).
    public var isSingleUser: Field<Bool> { "singleuser" }
}

extension Kernel {
    /// The namespace for the hypervisor values (`hv`).
    public struct Hypervisor: SysctlNamespace {
        /// See SysctlNamespace
        public typealias ParentNamespace = Kernel

        /// See SysctlNamespace
        public static var namePart: String { "hv" }

        /// Whether hypervisor is supported (`supported`).
        public var isSupported: Field<Bool> { "supported" }
    }

    /// The hypervisor values (`hv`).
    public var hypervisor: Hypervisor { .init() }
}

extension SysctlRootNamespace {
    /// The kernel values (`kern`).
    public var kernel: Kernel { .init() }
}
