import XCTest
@testable import Sysctl

/// This tests the name generation.
final class NameGenerationTests: XCTestCase {
    private let root = NameContainer(namespace: SysctlRootNamespace())

    func testHardwareNamespace() {
        XCTAssertEqual(root.hardware.machine, "hw.machine")
        XCTAssertEqual(root.hardware.model, "hw.model")
        XCTAssertEqual(root.hardware.numberOfCPUs, "hw.ncpu")
        XCTAssertEqual(root.hardware.physicalCPUs, "hw.physicalcpu")
        XCTAssertEqual(root.hardware.memorySize, "hw.memsize")
    }

    func testKernelNamespace() {
        XCTAssertEqual(root.kernel.bootDate, "kern.boottime")
        XCTAssertEqual(root.kernel.fullVersionText, "kern.version")
        XCTAssertEqual(root.kernel.hostID, "kern.hostid")
        XCTAssertEqual(root.kernel.hostname, "kern.hostname")
        XCTAssertEqual(root.kernel.hypervisor.isSupported, "kern.hv.supported")
        XCTAssertEqual(root.kernel.isSingleUser, "kern.singleuser")
        XCTAssertEqual(root.kernel.kind, "kern.ostype")
        XCTAssertEqual(root.kernel.osBuild, "kern.osversion")
        XCTAssertEqual(root.kernel.revision, "kern.osrevision")
        XCTAssertEqual(root.kernel.version, "kern.osrelease")
    }
    
    func testMachineDependentNamespace() {
        XCTAssertEqual(root.machineDependent.cpu.brandString, "machdep.cpu.brand_string")
    }

    func testNetworkingNamespace() {
        // IPv4
        XCTAssertEqual(root.networking.ipv4.icmp.answerBroadAndMulticastEchoRequests, "net.inet.icmp.bmcastecho")
        XCTAssertEqual(root.networking.ipv4.icmp.answerNetworkMaskRequests, "net.inet.icmp.maskrepl")
        XCTAssertEqual(root.networking.ipv4.ip.forwardingEnabled, "net.inet.ip.forwarding")
        XCTAssertEqual(root.networking.ipv4.ip.redirectsEnabled, "net.inet.ip.redirect")

        // IPv6
        XCTAssertEqual(root.networking.ipv6.icmp.acceptRedirects, "net.inet6.icmp6.rediraccept")
        XCTAssertEqual(root.networking.ipv6.icmp.redirectTimeout, "net.inet6.icmp6.redirtimeout")
        XCTAssertEqual(root.networking.ipv6.ip.forwardingEnabled, "net.inet6.ip6.forwarding")
        XCTAssertEqual(root.networking.ipv6.ip.redirectsEnabled, "net.inet6.ip6.redirect")
    }
}

// Small helper that gives access to names instead of values.
@dynamicMemberLookup
fileprivate struct NameContainer<Namespace: SysctlNamespace> {
    let namespace: Namespace

    subscript<ChildSpace: SysctlNamespace>(dynamicMember childSpace: KeyPath<Namespace, ChildSpace>) -> NameContainer<ChildSpace>
    where ChildSpace.ParentNamespace == Namespace
    {
        NameContainer<ChildSpace>(namespace: namespace[keyPath: childSpace])
    }

    subscript<Value: SysctlValue>(dynamicMember field: KeyPath<Namespace, Namespace.Field<Value>>) -> String {
        Namespace._buildName(for: namespace[keyPath: field])
    }
}
