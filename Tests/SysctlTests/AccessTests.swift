import Foundation
import Testing
import Sysctl
#if os(macOS)
fileprivate let isMacOS = true
#else
fileprivate let isMacOS = false
#endif

@Suite
struct AccessTests {
    private let sysctl = SystemControl()

    @Test
    func readingHardwareNamespace() {
        #expect(!sysctl.hardware.machine.isEmpty)
        #expect(!sysctl.hardware.model.isEmpty)
        #expect(sysctl.hardware.numberOfCPUs > 0)
        #expect(sysctl.hardware.physicalCPUs > 0)
        #expect(sysctl.hardware.memorySize > 0)
    }

    @Test
    func readingKernelNamespace() {
        #expect(!sysctl.kernel.kind.isEmpty)
        #expect(!sysctl.kernel.version.isEmpty)
        #expect(!sysctl.kernel.revision.isEmpty)
        #expect(!sysctl.kernel.fullVersionText.isEmpty)
        #expect(sysctl.kernel.hostID >= 0)
        #expect(!sysctl.kernel.hostname.isEmpty)
        #expect(sysctl.kernel.bootDate < Date())
    }

    @Test
    func readingMachineDependentNamespace() {
        #expect(!sysctl.machineDependent.cpu.brandString.isEmpty)
    }

    @Test
    func readingProcesses() {
        let all = sysctl.kernel.processes.all
        let ourPID = sysctl.kernel.processes.byPid[ProcessInfo.processInfo.processIdentifier]
#if compiler(>=6.2)
        #expect(unsafe all.map(\.kp_proc.p_pid).contains(ProcessInfo.processInfo.processIdentifier))
        #expect(unsafe ourPID.map(\.kp_proc.p_pid).contains(ProcessInfo.processInfo.processIdentifier))
#else
        #expect(all.map(\.kp_proc.p_pid).contains(ProcessInfo.processInfo.processIdentifier))
        #expect(ourPID.map(\.kp_proc.p_pid).contains(ProcessInfo.processInfo.processIdentifier))
#endif
    }

    // Writing always fails if we're not root.
    @Test(.enabled(if: isMacOS && getuid() == 0))
    func writingNetworking() throws {
#if os(macOS)
        let oldValue = sysctl.networking.ipv4.icmp.answerNetworkMaskRequests
        sysctl.networking.ipv4.icmp.answerNetworkMaskRequests = !oldValue
        #expect(sysctl.networking.ipv4.icmp.answerNetworkMaskRequests == !oldValue)
        sysctl.networking.ipv4.icmp.answerNetworkMaskRequests = oldValue
        #expect(sysctl.networking.ipv4.icmp.answerNetworkMaskRequests == oldValue)
#endif
    }
}
