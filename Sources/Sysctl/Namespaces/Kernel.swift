public import Darwin
public import Foundation

/// The namespace for the kernel values (`kern`).
public struct Kernel: SysctlFullyQualifiedNamespace {
    public typealias ParentNamespace = SysctlRootNamespace

    public static var namePart: String { "kern" }
    public static var managementInformationBasePart: CInt { CTL_KERN }

    /// The kind of kernel (`ostype`).
    public var kind: Field<String> {
        .init(managementInformationBasePart: KERN_OSTYPE, namePart: "ostype")
    }
    /// The version of the kernel (`osrelease`).
    public var version: Field<String> {
        .init(managementInformationBasePart: KERN_OSRELEASE, namePart: "osrelease")
    }
    /// The revision of the kernel (`osrevision`).
    public var revision: Field<String> {
        .init(managementInformationBasePart: KERN_OSREV, namePart: "osrevision")
    }
    /// The full version text of the kernel (`version`).
    public var fullVersionText: Field<String> {
        .init(managementInformationBasePart: KERN_VERSION, namePart: "version")
    }

    /// The OS build number (`osversion`).
    public var osBuild: Field<String> {
        .init(managementInformationBasePart: KERN_OSVERSION, namePart: "osversion")
    }

    /// The host ID (`hostid`).
    public var hostID: Field<CInt> {
        get { .init(managementInformationBasePart: KERN_HOSTID, namePart: "hostid") }
        nonmutating set {}
    }

    /// The hostname (`hostname`).
    public var hostname: Field<String> {
        get { .init(managementInformationBasePart: KERN_HOSTNAME, namePart: "hostname") }
        nonmutating set {}
    }

    /// The boot time (`boottime`).
    public var bootDate: Field<Date> {
        .init(managementInformationBasePart: KERN_BOOTTIME, namePart: "boottime")
    }

    /// Whether or not the system runs in single user mode (`singleuser`).
    public var isSingleUser: Field<Bool> { "singleuser" }

    /// Whether or not job control is available (`job_control`).
    public var isJobControlAvailable: Field<Bool> {
        .init(managementInformationBasePart: KERN_JOB_CONTROL, namePart: "job_control")
    }

    /// The maximum number of files that may be open on the system (`maxfiles`).
    public var maxOpenFiles: Field<CInt> {
        get { .init(managementInformationBasePart: KERN_MAXFILES, namePart: "maxfiles") }
        nonmutating set {}
    }

    /// The maximum number of files that may be open for a single process (`maxfilesperproc`).
    public var maxOpenFilesPerProcess: Field<CInt> {
        get { .init(managementInformationBasePart: KERN_MAXFILESPERPROC, namePart: "maxfilesperproc") }
        nonmutating set {}
    }

    /// The maximum number of concurrent processes allowed (`maxproc`).
    public var maxProcesses: Field<CInt> {
        .init(managementInformationBasePart: KERN_MAXPROC, namePart: "maxproc")
    }

    /// The maximum number of concurrent processes allowed per user (`maxvnodes`).
    public var maxProcessesPerUser: Field<CInt> {
        get { .init(managementInformationBasePart: KERN_MAXPROCPERUID, namePart: "maxprocperuid") }
        nonmutating set {}
    }

    /// The maximum number of virtual nodes allowed (`maxprocperuid`).
    public var maxVirtualNodes: Field<CInt> {
        get { .init(managementInformationBasePart: KERN_MAXVNODES, namePart: "maxvnodes") }
        nonmutating set {}
    }
}

extension Kernel {
    /// The namespace for the hypervisor values (`hv`).
    public struct Hypervisor: SysctlNamespace {
        public typealias ParentNamespace = Kernel

        public static var namePart: String { "hv" }

        /// Whether hypervisor is supported (`supported`).
        public var isSupported: Field<Bool> { "supported" }
    }

    /// The hypervisor values (`hv`).
    public var hypervisor: Hypervisor { .init() }
}

extension Kernel {
    /// The namespace for the processes (`proc`).
    public struct Processes: SysctlFullyQualifiedNamespace {
        public typealias ParentNamespace = Kernel

        /// Accesses processes by process identifier (PID).
        public struct ByPID: SysctlFullyQualifiedNamespace {
            public typealias ParentNamespace = Processes

            public static var namePart: String { "pid" }
            public static var managementInformationBasePart: CInt { KERN_PROC_PID }

            /// The process(es) for the given pid.
            public subscript(pid: CInt) -> Field<Array<kinfo_proc>> {
                .init(managementInformationBasePart: pid)
            }
        }

        public static var namePart: String { "proc" }
        public static var managementInformationBasePart: CInt { KERN_PROC }

        /// All processes (`all`).
        public var all: Field<Array<kinfo_proc>> {
            .init(managementInformationBasePart: KERN_PROC_ALL, namePart: "all")
        }
        /// Processes by identifier (`pid`).
        public var byPid: ByPID { .init() }
    }

    /// The processes (`proc`).
    public var processes: Processes { .init() }
}

extension SysctlRootNamespace {
    /// The kernel values (`kern`).
    public var kernel: Kernel { .init() }
}
