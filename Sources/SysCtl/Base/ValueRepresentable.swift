import Foundation

public protocol SysctlValueRepresentable: SysctlValue where SysctlPointerType == Self.SysctlValue.SysctlPointerType {
    associatedtype SysctlValue: Sysctl.SysctlValue

    var sysctlValue: SysctlValue { get }

    init(sysctlValue: SysctlValue)
}

extension SysctlValueRepresentable {
    @inlinable
    public init(sysctlPointer: UnsafePointer<SysctlValue.SysctlPointerType>) {
        self.init(sysctlValue: SysctlValue(sysctlPointer: sysctlPointer))
    }

    @inlinable
    public func withSysctlPointer<T>(do work: (UnsafePointer<SysctlValue.SysctlPointerType>, Int) throws -> T) rethrows -> T {
        try sysctlValue.withSysctlPointer(do: work)
    }
}

extension Bool: SysctlValueRepresentable {
    public typealias SysctlValue = CInt

    @inlinable
    public var sysctlValue: SysctlValue { self ? 1 : 0 }

    @inlinable
    public init(sysctlValue: SysctlValue) {
        self.init(sysctlValue != 0)
    }
}

extension Date: SysctlValueRepresentable {
    public typealias SysctlValue = timeval

    public var sysctlValue: SysctlValue {
        let timeInterval = timeIntervalSince1970
        let seconds = __darwin_time_t(timeInterval)
        let uSeconds = __darwin_suseconds_t((timeInterval - TimeInterval(seconds)) * TimeInterval(USEC_PER_SEC))
        return timeval(tv_sec: seconds, tv_usec: uSeconds)
    }

    public init(sysctlValue: SysctlValue) {
        let timeInterval = TimeInterval(sysctlValue.tv_sec) + (TimeInterval(sysctlValue.tv_usec) / TimeInterval(USEC_PER_SEC))
        self.init(timeIntervalSince1970: timeInterval)
    }
}
