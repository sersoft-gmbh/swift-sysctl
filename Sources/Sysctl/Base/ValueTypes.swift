import Darwin
import Foundation

/// Describes a type that can be read from / written to sysctl.
/// Usually, no new conformances to this protocol are necessary and the set of default conformances below will suffice.
public protocol SysctlValue {
    /// The underlyling type of the pointer read from / written to sysctl.
    associatedtype SysctlPointerType

    /// Creates the type from a pointer read from sysctl.
    init(sysctlPointer: UnsafePointer<SysctlPointerType>)

    /// Retrieves a pointer to write to sysctl. Note that the pointer should only be alive during the execution of `work`.
    /// - Parameter work: The closure during which the pointer should be alive. The second parameter should be the size of the pointer.
    func withSysctlPointer<T>(do work: (UnsafePointer<SysctlPointerType>, Int) throws -> T) rethrows -> T
}

extension SysctlValue where SysctlPointerType == Self {
    /// See `SysctlValue.init(sysctlPointer:)`
    public init(sysctlPointer: UnsafePointer<SysctlPointerType>) {
        self = sysctlPointer.pointee
    }

    /// See `SysctlValue.withSysctlPointer(do:)`
    public func withSysctlPointer<T>(do work: (UnsafePointer<SysctlPointerType>, Int) throws -> T) rethrows -> T {
        try withUnsafePointer(to: self, { try work($0, MemoryLayout<SysctlPointerType>.size) })
    }
}

extension String: SysctlValue {
    /// See `SysctlValue.SysctlPointerType`
    public typealias SysctlPointerType = CChar

    /// See `SysctlValue.init(sysctlPointer:)`
    @inlinable
    public init(sysctlPointer: UnsafePointer<SysctlPointerType>) {
        self.init(cString: sysctlPointer)
    }

    /// See `SysctlValue.withSysctlPointer(do:)`
    @inlinable
    public func withSysctlPointer<T>(do work: (UnsafePointer<SysctlPointerType>, Int) throws -> T) rethrows -> T {
        try withCString { try work($0, utf8.count) }
    }
}

extension CInt: SysctlValue {
    /// See `SysctlValue.SysctlPointerType`
    public typealias SysctlPointerType = Self
}

/// Make 64-bit C Integers conform to SysctlValue for
/// large numbers (e.g., memsize)
extension CLongLong: SysctlValue {
    /// See `SysctlValue.SysctlPointerType`
    public typealias SysctlPointerType = Self
}

extension timeval: SysctlValue {
    /// See `SysctlValue.SysctlPointerType`
    public typealias SysctlPointerType = Self
}

extension clockinfo: SysctlValue {
    /// See `SysctlValue.SysctlPointerType`
    public typealias SysctlPointerType = Self
}

extension loadavg: SysctlValue {
    /// See `SysctlValue.SysctlPointerType`
    public typealias SysctlPointerType = Self
}
