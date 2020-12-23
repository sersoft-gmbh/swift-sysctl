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

extension timeval: SysctlValue {
    public typealias SysctlPointerType = Self
}
