import XCTest
import Sysctl

/// This tests some basic accesses that are true on all systems.
final class AccessTests: XCTestCase {
    private let sysctl = SystemControl()

    func testReading() {
        XCTAssertFalse(sysctl.hardware.machine.isEmpty)
        XCTAssertLessThan(sysctl.kernel.bootDate, Date())
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
