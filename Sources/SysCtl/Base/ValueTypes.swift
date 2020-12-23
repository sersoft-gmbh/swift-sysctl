import Darwin
import Foundation

public protocol SysctlValue {
    associatedtype SysctlPointerType

    func withSysctlPointer<T>(do work: (UnsafePointer<SysctlPointerType>, Int) throws -> T) rethrows -> T

    init(sysctlPointer: UnsafePointer<SysctlPointerType>)
}

extension SysctlValue where SysctlPointerType == Self {
    public init(sysctlPointer: UnsafePointer<SysctlPointerType>) {
        self = sysctlPointer.pointee
    }

    public func withSysctlPointer<T>(do work: (UnsafePointer<SysctlPointerType>, Int) throws -> T) rethrows -> T {
        try withUnsafePointer(to: self, { try work($0, MemoryLayout<SysctlPointerType>.size) })
    }
}

extension String: SysctlValue {
    public typealias SysctlPointerType = CChar

    @inlinable
    public init(sysctlPointer: UnsafePointer<SysctlPointerType>) {
        self.init(cString: sysctlPointer)
    }

    @inlinable
    public func withSysctlPointer<T>(do work: (UnsafePointer<SysctlPointerType>, Int) throws -> T) rethrows -> T {
        try withCString { try work($0, utf8.count) }
    }
}

extension Int: SysctlValue {
    public typealias SysctlPointerType = Self
}
extension Int8: SysctlValue {
    public typealias SysctlPointerType = Self
}
extension Int16: SysctlValue {
    public typealias SysctlPointerType = Self
}
extension Int32: SysctlValue {
    public typealias SysctlPointerType = Self
}
extension Int64: SysctlValue {
    public typealias SysctlPointerType = Self
}

extension UInt: SysctlValue {
    public typealias SysctlPointerType = Self
}
extension UInt8: SysctlValue {
    public typealias SysctlPointerType = Self
}
extension UInt16: SysctlValue {
    public typealias SysctlPointerType = Self
}
extension UInt32: SysctlValue {
    public typealias SysctlPointerType = Self
}
extension UInt64: SysctlValue {
    public typealias SysctlPointerType = Self
}

extension Double: SysctlValue {
    public typealias SysctlPointerType = Self
}

extension Bool: SysctlValue {
    public typealias SysctlPointerType = CInt.SysctlPointerType

    @inlinable
    public init(sysctlPointer: UnsafePointer<SysctlPointerType>) {
        self.init(CInt(sysctlPointer: sysctlPointer) != 0)
    }

    @inlinable
    public func withSysctlPointer<T>(do work: (UnsafePointer<SysctlPointerType>, Int) throws -> T) rethrows -> T {
        try CInt(self ? 1 : 0).withSysctlPointer(do: work)
    }
}

extension timeval: SysctlValue {
    public typealias SysctlPointerType = Self
}

extension Date: SysctlValue {
    public typealias SysctlPointerType = timeval

    public init(sysctlPointer: UnsafePointer<SysctlPointerType>) {
        let val = timeval(sysctlPointer: sysctlPointer)
        let timeInterval = TimeInterval(val.tv_sec) + (TimeInterval(val.tv_usec) / TimeInterval(USEC_PER_SEC))
        self.init(timeIntervalSince1970: timeInterval)
    }

    public func withSysctlPointer<T>(do work: (UnsafePointer<SysctlPointerType>, Int) throws -> T) rethrows -> T {
        let timeInterval = timeIntervalSince1970
        let seconds = __darwin_time_t(timeInterval)
        let uSeconds = __darwin_suseconds_t((timeInterval - TimeInterval(seconds)) * TimeInterval(USEC_PER_SEC))
        return try timeval(tv_sec: seconds, tv_usec: uSeconds).withSysctlPointer(do: work)
    }
}
