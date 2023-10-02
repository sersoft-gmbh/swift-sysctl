import XCTest
@testable import Sysctl

final class NameGenerationTests: XCTestCase {
    private let root = LookupContainer(namespace: SysctlRootNamespace())

    func testHardwareNamespace() {
        XCTAssertEqual(root.hardware, "hw")
        XCTAssertEqual(root.hardware, [CTL_HW])

        XCTAssertEqual(root.hardware.machine, "hw.machine")
        XCTAssertEqual(root.hardware.machine, [CTL_HW, HW_MACHINE])
        XCTAssertEqual(root.hardware.model, "hw.model")
        XCTAssertEqual(root.hardware.model, [CTL_HW, HW_MODEL])
        XCTAssertEqual(root.hardware.numberOfCPUs, "hw.ncpu")
        XCTAssertEqual(root.hardware.numberOfCPUs, [CTL_HW, HW_NCPU])
        XCTAssertEqual(root.hardware.physicalCPUs, "hw.physicalcpu")
        XCTAssertNil(root.hardware.physicalCPUs as Array<CInt>?)
        XCTAssertEqual(root.hardware.memorySize, "hw.memsize")
        XCTAssertEqual(root.hardware.memorySize, [CTL_HW, HW_MEMSIZE])
    }

    func testKernelNamespace() {
        XCTAssertEqual(root.kernel, "kern")
        XCTAssertEqual(root.kernel, [CTL_KERN])

        XCTAssertEqual(root.kernel.bootDate, "kern.boottime")
        XCTAssertEqual(root.kernel.bootDate, [CTL_KERN, KERN_BOOTTIME])
        XCTAssertEqual(root.kernel.fullVersionText, "kern.version")
        XCTAssertEqual(root.kernel.fullVersionText, [CTL_KERN, KERN_VERSION])
        XCTAssertEqual(root.kernel.hostID, "kern.hostid")
        XCTAssertEqual(root.kernel.hostID, [CTL_KERN, KERN_HOSTID])
        XCTAssertEqual(root.kernel.hostname, "kern.hostname")
        XCTAssertEqual(root.kernel.hostname, [CTL_KERN, KERN_HOSTNAME])
        XCTAssertEqual(root.kernel.hypervisor, "kern.hv")
        XCTAssertNil(root.kernel.hypervisor as Array<CInt>?)
        XCTAssertEqual(root.kernel.hypervisor.isSupported, "kern.hv.supported")
        XCTAssertNil(root.kernel.hypervisor.isSupported as Array<CInt>?)
        XCTAssertEqual(root.kernel.isSingleUser, "kern.singleuser")
        XCTAssertNil(root.kernel.isSingleUser as Array<CInt>?)
        XCTAssertEqual(root.kernel.kind, "kern.ostype")
        XCTAssertEqual(root.kernel.kind, [CTL_KERN, KERN_OSTYPE])
        XCTAssertEqual(root.kernel.osBuild, "kern.osversion")
        XCTAssertEqual(root.kernel.osBuild, [CTL_KERN, KERN_OSVERSION])
        XCTAssertEqual(root.kernel.revision, "kern.osrevision")
        XCTAssertEqual(root.kernel.revision, [CTL_KERN, KERN_OSREV])
        XCTAssertEqual(root.kernel.version, "kern.osrelease")
        XCTAssertEqual(root.kernel.version, [CTL_KERN, KERN_OSRELEASE])

        XCTAssertEqual(root.kernel.isJobControlAvailable, "kern.job_control")
        XCTAssertEqual(root.kernel.isJobControlAvailable, [CTL_KERN, KERN_JOB_CONTROL])
        XCTAssertEqual(root.kernel.maxOpenFiles, "kern.maxfiles")
        XCTAssertEqual(root.kernel.maxOpenFiles, [CTL_KERN, KERN_MAXFILES])
        XCTAssertEqual(root.kernel.maxOpenFilesPerProcess, "kern.maxfilesperproc")
        XCTAssertEqual(root.kernel.maxOpenFilesPerProcess, [CTL_KERN, KERN_MAXFILESPERPROC])
        XCTAssertEqual(root.kernel.maxProcesses, "kern.maxproc")
        XCTAssertEqual(root.kernel.maxProcesses, [CTL_KERN, KERN_MAXPROC])
        XCTAssertEqual(root.kernel.maxProcessesPerUser, "kern.maxprocperuid")
        XCTAssertEqual(root.kernel.maxProcessesPerUser, [CTL_KERN, KERN_MAXPROCPERUID])
        XCTAssertEqual(root.kernel.maxVirtualNodes, "kern.maxvnodes")
        XCTAssertEqual(root.kernel.maxVirtualNodes, [CTL_KERN, KERN_MAXVNODES])

        XCTAssertEqual(root.kernel.processes, "kern.proc")
        XCTAssertEqual(root.kernel.processes, [CTL_KERN, KERN_PROC])
        XCTAssertEqual(root.kernel.processes.all, "kern.proc.all")
        XCTAssertEqual(root.kernel.processes.all, [CTL_KERN, KERN_PROC, KERN_PROC_ALL])
        XCTAssertEqual(root.kernel.processes.byPid, "kern.proc.pid")
        XCTAssertEqual(root.kernel.processes.byPid, [CTL_KERN, KERN_PROC, KERN_PROC_PID])

        XCTAssertNil(root.kernel.processes.byPid[12345] as String?)
        XCTAssertEqual(root.kernel.processes.byPid[12345], [CTL_KERN, KERN_PROC, KERN_PROC_PID, 12345])
    }
    
    func testMachineDependentNamespace() {
        XCTAssertEqual(root.machineDependent, "machdep")
        XCTAssertEqual(root.machineDependent, [CTL_MACHDEP])

        XCTAssertEqual(root.machineDependent.cpu.brandString, "machdep.cpu.brand_string")
    }

    func testVirtualMemoryNamespace() {
        XCTAssertEqual(root.virtualMemory, "vm")
        XCTAssertEqual(root.virtualMemory, [CTL_VM])

        XCTAssertEqual(root.virtualMemory.isSwappingEnabled, "vm.swap_enabled")
        XCTAssertNil(root.virtualMemory.isSwappingEnabled as Array<CInt>?)
        XCTAssertEqual(root.virtualMemory.loadAverageHistory, "vm.loadavg")
        XCTAssertEqual(root.virtualMemory.loadAverageHistory, [CTL_VM, VM_LOADAVG])
    }

    func testUserNamespace() {
        XCTAssertEqual(root.user, "user")
        XCTAssertEqual(root.user, [CTL_USER])

        XCTAssertEqual(root.user.standardSearchPath, "user.cs_path")
        XCTAssertEqual(root.user.standardSearchPath, [CTL_USER, USER_CS_PATH])
    }

    func testNetworkingNamespace() {
        XCTAssertEqual(root.networking, "net")
        XCTAssertEqual(root.networking, [CTL_NET])

        // IPv4
        XCTAssertEqual(root.networking.ipv4, "net.inet")
        XCTAssertEqual(root.networking.ipv4, [CTL_NET, PF_INET])
        XCTAssertEqual(root.networking.ipv4.icmp, "net.inet.icmp")
        XCTAssertNil(root.networking.ipv4.icmp as Array<CInt>?)
        XCTAssertEqual(root.networking.ipv4.ip, "net.inet.ip")
        XCTAssertNil(root.networking.ipv4.ip as Array<CInt>?)

        XCTAssertEqual(root.networking.ipv4.icmp.answerBroadAndMulticastEchoRequests, "net.inet.icmp.bmcastecho")
        XCTAssertNil(root.networking.ipv4.icmp.answerBroadAndMulticastEchoRequests as Array<CInt>?)
#if os(macOS)
        XCTAssertEqual(root.networking.ipv4.icmp.answerNetworkMaskRequests, "net.inet.icmp.maskrepl")
        XCTAssertNil(root.networking.ipv4.icmp.answerNetworkMaskRequests as Array<CInt>?)
#endif

        XCTAssertEqual(root.networking.ipv4.ip.forwardingEnabled, "net.inet.ip.forwarding")
        XCTAssertNil(root.networking.ipv4.ip.forwardingEnabled as Array<CInt>?)
        XCTAssertEqual(root.networking.ipv4.ip.redirectsEnabled, "net.inet.ip.redirect")
        XCTAssertNil(root.networking.ipv4.ip.redirectsEnabled as Array<CInt>?)
        XCTAssertEqual(root.networking.ipv4.ip.timeToLive, "net.inet.ip.ttl")
        XCTAssertNil(root.networking.ipv4.ip.timeToLive as Array<CInt>?)

#if os(macOS)
        XCTAssertEqual(root.networking.ipv4.udp.checksumEnabled, "net.inet.udp.checksum")
        XCTAssertNil(root.networking.ipv4.udp.checksumEnabled as Array<CInt>?)
#endif

        // IPv6
        XCTAssertEqual(root.networking.ipv6, "net.inet6")
        XCTAssertEqual(root.networking.ipv6, [CTL_NET, PF_INET6])
        XCTAssertEqual(root.networking.ipv6.icmp, "net.inet6.icmp6")
        XCTAssertNil(root.networking.ipv6.icmp as Array<CInt>?)
        XCTAssertEqual(root.networking.ipv6.ip, "net.inet6.ip6")
        XCTAssertNil(root.networking.ipv6.ip as Array<CInt>?)

        XCTAssertEqual(root.networking.ipv6.icmp.acceptRedirects, "net.inet6.icmp6.rediraccept")
        XCTAssertNil(root.networking.ipv6.icmp.acceptRedirects as Array<CInt>?)
        XCTAssertEqual(root.networking.ipv6.icmp.redirectTimeout, "net.inet6.icmp6.redirtimeout")
        XCTAssertNil(root.networking.ipv6.icmp.redirectTimeout as Array<CInt>?)
        XCTAssertEqual(root.networking.ipv6.ip.forwardingEnabled, "net.inet6.ip6.forwarding")
        XCTAssertNil(root.networking.ipv6.ip.forwardingEnabled as Array<CInt>?)
        XCTAssertEqual(root.networking.ipv6.ip.redirectsEnabled, "net.inet6.ip6.redirect")
        XCTAssertNil(root.networking.ipv6.ip.redirectsEnabled as Array<CInt>?)
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
}
