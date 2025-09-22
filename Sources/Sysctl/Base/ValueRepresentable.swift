public import Foundation

/// Describes a type that can be represented by a ``SyctlValue`` conforming type.
/// It will automatically provide a ``SysctlValue`` conformance for this type, using the underlying ``SysctlValue`` type.
public protocol SysctlValueRepresentable<SysctlValue>: Sysctl.SysctlValue
where SysctlPointerType == Self.SysctlValue.SysctlPointerType
{
    /// The underlying ``SysctlValue`` conforming type.
    associatedtype SysctlValue: Sysctl.SysctlValue

    /// The underyling value.
    var sysctlValue: SysctlValue { get }

    /// Creates the type from the underlying value.
    init(sysctlValue: SysctlValue)
}

extension SysctlValueRepresentable {
    @available(*, deprecated, message: "Use initializer with capacity")
    public init(sysctlPointer: UnsafePointer<SysctlValue.SysctlPointerType>) {
        self.init(sysctlValue: SysctlValue(sysctlPointer: sysctlPointer))
    }

    @inlinable
    public init(sysctlPointer: UnsafePointer<SysctlValue.SysctlPointerType>, capacity: Int) {
        self.init(sysctlValue: SysctlValue(sysctlPointer: sysctlPointer, capacity: capacity))
    }

    @inlinable
    public func withSysctlPointer<T>(do work: (UnsafePointer<SysctlValue.SysctlPointerType>, Int) throws -> T) rethrows -> T {
        try sysctlValue.withSysctlPointer(do: work)
    }
}

extension Bool: SysctlValueRepresentable {
    public typealias SysctlValue = CInt // Bools are actually represented by way too big ints - CSignedChar would suffice but is reported as invalid argument.

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
        let seconds = time_t(timeInterval)
        let uSeconds = suseconds_t((timeInterval - TimeInterval(seconds)) * TimeInterval(USEC_PER_SEC))
        return timeval(tv_sec: seconds, tv_usec: uSeconds)
    }

    public init(sysctlValue: SysctlValue) {
        let timeInterval = TimeInterval(sysctlValue.tv_sec) + (TimeInterval(sysctlValue.tv_usec) / TimeInterval(USEC_PER_SEC))
        self.init(timeIntervalSince1970: timeInterval)
    }
}
