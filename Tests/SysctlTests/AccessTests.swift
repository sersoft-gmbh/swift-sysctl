import XCTest
import Sysctl

/// This tests some basic accesses that are true on all systems.
final class AccessTests: XCTestCase {
    private let sysctl = SystemControl()

    func testReading() {
        // hardware
        XCTAssertFalse(sysctl.hardware.machine.isEmpty)
        XCTAssertFalse(sysctl.hardware.model.isEmpty)
        XCTAssertGreaterThan(sysctl.hardware.numberOfCPUs, 0)
        XCTAssertGreaterThan(sysctl.hardware.physicalCPUs, 0)
        XCTAssertFalse(sysctl.hardware.model.isEmpty)
        // kernel
        XCTAssertFalse(sysctl.kernel.kind.isEmpty)
        XCTAssertFalse(sysctl.kernel.version.isEmpty)
        XCTAssertFalse(sysctl.kernel.revision.isEmpty)
        XCTAssertFalse(sysctl.kernel.fullVersionText.isEmpty)
        XCTAssertGreaterThanOrEqual(sysctl.kernel.hostID, 0)
        XCTAssertFalse(sysctl.kernel.hostname.isEmpty)
        XCTAssertLessThan(sysctl.kernel.bootDate, Date())
        // machdep
        XCTAssertFalse(sysctl.machdep.cpu.brandString.isEmpty)
    }

    func testWriting() throws {
        // Writing always fails if we're not root.
        try XCTSkipUnless(getuid() == 0)
        let oldValue = sysctl.networking.ipv4.icmp.answerNetworkMaskRequests
        sysctl.networking.ipv4.icmp.answerNetworkMaskRequests = !oldValue
        XCTAssertEqual(sysctl.networking.ipv4.icmp.answerNetworkMaskRequests, !oldValue)
        sysctl.networking.ipv4.icmp.answerNetworkMaskRequests = oldValue
        XCTAssertEqual(sysctl.networking.ipv4.icmp.answerNetworkMaskRequests, oldValue)
    }
}
