import Foundation
import Testing
@testable import Sysctl

@Suite
struct NameGenerationTests {
    private let root = LookupContainer(namespace: SysctlRootNamespace())

    @Test
    func hardwareNamespace() {
        #expect(root.hardware == "hw")
        #expect(root.hardware == [CTL_HW])

        #expect(root.hardware.machine == "hw.machine")
        #expect(root.hardware.machine == [CTL_HW, HW_MACHINE])
        #expect(root.hardware.model == "hw.model")
        #expect(root.hardware.model == [CTL_HW, HW_MODEL])
        #expect(root.hardware.numberOfCPUs == "hw.ncpu")
        #expect(root.hardware.numberOfCPUs == [CTL_HW, HW_NCPU])
        #expect(root.hardware.physicalCPUs == "hw.physicalcpu")
        #expect(root.hardware.physicalCPUs as Array<CInt>? == nil)
        #expect(root.hardware.memorySize == "hw.memsize")
        #expect(root.hardware.memorySize == [CTL_HW, HW_MEMSIZE])
    }

    @Test
    func kernelNamespace() {
        #expect(root.kernel == "kern")
        #expect(root.kernel == [CTL_KERN])

        #expect(root.kernel.bootDate == "kern.boottime")
        #expect(root.kernel.bootDate == [CTL_KERN, KERN_BOOTTIME])
        #expect(root.kernel.fullVersionText == "kern.version")
        #expect(root.kernel.fullVersionText == [CTL_KERN, KERN_VERSION])
        #expect(root.kernel.hostID == "kern.hostid")
        #expect(root.kernel.hostID == [CTL_KERN, KERN_HOSTID])
        #expect(root.kernel.hostname == "kern.hostname")
        #expect(root.kernel.hostname == [CTL_KERN, KERN_HOSTNAME])
        #expect(root.kernel.hypervisor == "kern.hv")
        #expect(root.kernel.hypervisor as Array<CInt>? == nil)
        #expect(root.kernel.hypervisor.isSupported == "kern.hv.supported")
        #expect(root.kernel.hypervisor.isSupported as Array<CInt>? == nil)
        #expect(root.kernel.isSingleUser == "kern.singleuser")
        #expect(root.kernel.isSingleUser as Array<CInt>? == nil)
        #expect(root.kernel.kind == "kern.ostype")
        #expect(root.kernel.kind == [CTL_KERN, KERN_OSTYPE])
        #expect(root.kernel.osBuild == "kern.osversion")
        #expect(root.kernel.osBuild == [CTL_KERN, KERN_OSVERSION])
        #expect(root.kernel.revision == "kern.osrevision")
        #expect(root.kernel.revision == [CTL_KERN, KERN_OSREV])
        #expect(root.kernel.version == "kern.osrelease")
        #expect(root.kernel.version == [CTL_KERN, KERN_OSRELEASE])

        #expect(root.kernel.isJobControlAvailable == "kern.job_control")
        #expect(root.kernel.isJobControlAvailable == [CTL_KERN, KERN_JOB_CONTROL])
        #expect(root.kernel.maxOpenFiles == "kern.maxfiles")
        #expect(root.kernel.maxOpenFiles == [CTL_KERN, KERN_MAXFILES])
        #expect(root.kernel.maxOpenFilesPerProcess == "kern.maxfilesperproc")
        #expect(root.kernel.maxOpenFilesPerProcess == [CTL_KERN, KERN_MAXFILESPERPROC])
        #expect(root.kernel.maxProcesses == "kern.maxproc")
        #expect(root.kernel.maxProcesses == [CTL_KERN, KERN_MAXPROC])
        #expect(root.kernel.maxProcessesPerUser == "kern.maxprocperuid")
        #expect(root.kernel.maxProcessesPerUser == [CTL_KERN, KERN_MAXPROCPERUID])
        #expect(root.kernel.maxVirtualNodes == "kern.maxvnodes")
        #expect(root.kernel.maxVirtualNodes == [CTL_KERN, KERN_MAXVNODES])

        #expect(root.kernel.processes == "kern.proc")
        #expect(root.kernel.processes == [CTL_KERN, KERN_PROC])
        #expect(root.kernel.processes.all == "kern.proc.all")
        #expect(root.kernel.processes.all == [CTL_KERN, KERN_PROC, KERN_PROC_ALL])
        #expect(root.kernel.processes.byPid == "kern.proc.pid")
        #expect(root.kernel.processes.byPid == [CTL_KERN, KERN_PROC, KERN_PROC_PID])

        #expect(root.kernel.processes.byPid[12345] as String? == nil)
        #expect(root.kernel.processes.byPid[12345] == [CTL_KERN, KERN_PROC, KERN_PROC_PID, 12345])
    }

    @Test
    func machineDependentNamespace() {
        #expect(root.machineDependent == "machdep")
        #expect(root.machineDependent == [CTL_MACHDEP])

        #expect(root.machineDependent.cpu.brandString == "machdep.cpu.brand_string")
    }

    @Test
    func virtualMemoryNamespace() {
        #expect(root.virtualMemory == "vm")
        #expect(root.virtualMemory == [CTL_VM])

        #expect(root.virtualMemory.isSwappingEnabled == "vm.swap_enabled")
        #expect(root.virtualMemory.isSwappingEnabled as Array<CInt>? == nil)
        #expect(root.virtualMemory.loadAverageHistory == "vm.loadavg")
        #expect(root.virtualMemory.loadAverageHistory == [CTL_VM, VM_LOADAVG])
    }

    @Test
    func userNamespace() {
        #expect(root.user == "user")
        #expect(root.user == [CTL_USER])

        #expect(root.user.standardSearchPath == "user.cs_path")
        #expect(root.user.standardSearchPath == [CTL_USER, USER_CS_PATH])
    }

    @Test
    func networkingNamespace() {
        #expect(root.networking == "net")
        #expect(root.networking == [CTL_NET])

        // IPv4
        #expect(root.networking.ipv4 == "net.inet")
        #expect(root.networking.ipv4 == [CTL_NET, PF_INET])
        #expect(root.networking.ipv4.icmp == "net.inet.icmp")
        #expect(root.networking.ipv4.icmp as Array<CInt>? == nil)
        #expect(root.networking.ipv4.ip == "net.inet.ip")
        #expect(root.networking.ipv4.ip as Array<CInt>? == nil)

        #expect(root.networking.ipv4.icmp.answerBroadAndMulticastEchoRequests == "net.inet.icmp.bmcastecho")
        #expect(root.networking.ipv4.icmp.answerBroadAndMulticastEchoRequests as Array<CInt>? == nil)
#if os(macOS)
        #expect(root.networking.ipv4.icmp.answerNetworkMaskRequests == "net.inet.icmp.maskrepl")
        #expect(root.networking.ipv4.icmp.answerNetworkMaskRequests as Array<CInt>? == nil)
#endif

        #expect(root.networking.ipv4.ip.forwardingEnabled == "net.inet.ip.forwarding")
        #expect(root.networking.ipv4.ip.forwardingEnabled as Array<CInt>? == nil)
        #expect(root.networking.ipv4.ip.redirectsEnabled == "net.inet.ip.redirect")
        #expect(root.networking.ipv4.ip.redirectsEnabled as Array<CInt>? == nil)
        #expect(root.networking.ipv4.ip.timeToLive == "net.inet.ip.ttl")
        #expect(root.networking.ipv4.ip.timeToLive as Array<CInt>? == nil)

#if os(macOS)
        #expect(root.networking.ipv4.udp.checksumEnabled == "net.inet.udp.checksum")
        #expect(root.networking.ipv4.udp.checksumEnabled as Array<CInt>? == nil)
#endif

        // IPv6
        #expect(root.networking.ipv6 == "net.inet6")
        #expect(root.networking.ipv6 == [CTL_NET, PF_INET6])
        #expect(root.networking.ipv6.icmp == "net.inet6.icmp6")
        #expect(root.networking.ipv6.icmp as Array<CInt>? == nil)
        #expect(root.networking.ipv6.ip == "net.inet6.ip6")
        #expect(root.networking.ipv6.ip as Array<CInt>? == nil)

        #expect(root.networking.ipv6.icmp.acceptRedirects == "net.inet6.icmp6.rediraccept")
        #expect(root.networking.ipv6.icmp.acceptRedirects as Array<CInt>? == nil)
        #expect(root.networking.ipv6.icmp.redirectTimeout == "net.inet6.icmp6.redirtimeout")
        #expect(root.networking.ipv6.icmp.redirectTimeout as Array<CInt>? == nil)
        #expect(root.networking.ipv6.ip.forwardingEnabled == "net.inet6.ip6.forwarding")
        #expect(root.networking.ipv6.ip.forwardingEnabled as Array<CInt>? == nil)
        #expect(root.networking.ipv6.ip.redirectsEnabled == "net.inet6.ip6.redirect")
        #expect(root.networking.ipv6.ip.redirectsEnabled as Array<CInt>? == nil)
    }
}

// Small helper that gives access to names and mibs instead of values.
@dynamicMemberLookup
fileprivate struct LookupContainer<Namespace: SysctlNamespace>: Sendable {
    let namespace: Namespace

    subscript<ChildSpace: SysctlNamespace>(dynamicMember childSpace: KeyPath<Namespace, ChildSpace>) -> LookupContainer<ChildSpace>
    where ChildSpace.ParentNamespace == Namespace
    {
        LookupContainer<ChildSpace>(namespace: namespace[keyPath: childSpace])
    }

#if compiler(>=6.2)
    @safe
    subscript<ChildSpace: SysctlNamespace>(dynamicMember _: KeyPath<Namespace, ChildSpace>) -> String
    where ChildSpace.ParentNamespace == Namespace
    {
        ChildSpace._nameParts().joined(separator: ".")
    }

    @safe
    subscript<ChildSpace: SysctlNamespace>(dynamicMember _: KeyPath<Namespace, ChildSpace>) -> Array<CInt>?
    where ChildSpace.ParentNamespace == Namespace
    {
        ChildSpace._mibParts()
    }

    @safe
    subscript(dynamicMember field: KeyPath<Namespace, Namespace.Field<some SysctlValue>>) -> String? {
        namespace[keyPath: field]._buildName()
    }

    @safe
    subscript(dynamicMember field: KeyPath<Namespace, Namespace.Field<some SysctlValue>>) -> Array<CInt>? {
        namespace[keyPath: field]._buildMib()
    }
#else
    subscript<ChildSpace: SysctlNamespace>(dynamicMember _: KeyPath<Namespace, ChildSpace>) -> String
    where ChildSpace.ParentNamespace == Namespace
    {
        ChildSpace._nameParts().joined(separator: ".")
    }

    subscript<ChildSpace: SysctlNamespace>(dynamicMember _: KeyPath<Namespace, ChildSpace>) -> Array<CInt>?
    where ChildSpace.ParentNamespace == Namespace
    {
        ChildSpace._mibParts()
    }

    subscript(dynamicMember field: KeyPath<Namespace, Namespace.Field<some SysctlValue>>) -> String? {
        namespace[keyPath: field]._buildName()
    }

    subscript(dynamicMember field: KeyPath<Namespace, Namespace.Field<some SysctlValue>>) -> Array<CInt>? {
        namespace[keyPath: field]._buildMib()
    }
#endif
}
