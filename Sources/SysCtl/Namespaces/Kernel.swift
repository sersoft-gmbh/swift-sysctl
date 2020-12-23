import struct Foundation.Date

public struct Kernel: SysctlNamespace {
    public typealias ParentNamespace = SysctlRootNamespace

    public static var sysctlNamePart: String { "kern" }


    public var kind: Field<String> { "ostype" }
    public var version: Field<String> { "osrelease" }
    public var revision: Field<String> { "osrevision" }
    public var fullVersion: Field<String> { "version" }

    public var osBuild: Field<String> { "osversion" }

    public var hostid: Field<CInt> {
        get { "hostid" }
        nonmutating set {}
    }
    public var hostname: Field<String> { "hostname" }

    public var bootDate: Field<Date> { "boottime" }

    public var isSingleUser: Field<Bool> { "singleuser" }
}

extension Kernel {
    public struct HyperVisor: SysctlNamespace {
        public typealias ParentNamespace = Kernel

        public static var sysctlNamePart: String { "hv" }

        public var isSupported: Field<Bool> { "supported" }
    }

    public var hyperVisor: HyperVisor { .init() }
}

extension SysctlRootNamespace {
    public var kernel: Kernel { .init() }
}
