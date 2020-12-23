import XCTest
@testable import Sysctl

final class SysctlTests: XCTestCase {
    let sysctl = SystemControl()

    func testHardwareLookup() {
        XCTAssertEqual(sysctl.hardware.machine, "arm64")
    }

    func testKernelLookup() {
        XCTAssertFalse(sysctl.kernel.isSingleUser)
        XCTAssertLessThan(sysctl.kernel.bootDate, Date())
        XCTAssertTrue(sysctl.kernel.hyperVisor.isSupported)
    }

    func testNetwork() {
        let oldValue = sysctl.network.ipv4.icmp.answerNetworkMaskRequests
        XCTAssertFalse(oldValue)
        // Writing always fails if we're not root.
        if getuid() == 0 {
            sysctl.network.ipv4.icmp.answerNetworkMaskRequests = true
            XCTAssertTrue(sysctl.network.ipv4.icmp.answerNetworkMaskRequests)
            sysctl.network.ipv4.icmp.answerNetworkMaskRequests = oldValue
            XCTAssertFalse(sysctl.network.ipv4.icmp.answerNetworkMaskRequests)
        }
    }
}
