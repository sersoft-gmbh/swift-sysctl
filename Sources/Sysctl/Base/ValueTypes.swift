public import Darwin

/// Describes a type that can be read from / written to sysctl.
/// Usually, no new conformances to this protocol are necessary and the set of default conformances below will suffice.
public protocol SysctlValue {
    /// The underlyling type of the pointer read from / written to sysctl.
    associatedtype SysctlPointerType

    /// Creates the type from a pointer read from sysctl.
    init(sysctlPointer: UnsafePointer<SysctlPointerType>, capacity: Int)

    /// Creates the type from a pointer read from sysctl.
    @available(*, deprecated, message: "Use initializer with capacity")
    init(sysctlPointer: UnsafePointer<SysctlPointerType>)

    /// Retrieves a pointer to write to sysctl. Note that the pointer should only be alive during the execution of `work`.
    /// - Parameter work: The closure during which the pointer should be alive. The second parameter should be the size of the pointer.
    func withSysctlPointer<T>(do work: (UnsafePointer<SysctlPointerType>, Int) throws -> T) rethrows -> T
}

extension SysctlValue {
    @available(*, deprecated, message: "Implement this yourself")
    public init(sysctlPointer: UnsafePointer<SysctlPointerType>, capacity: Int) {
        self.init(sysctlPointer: sysctlPointer)
    }

    @available(*, deprecated, message: "Use initializer with capacity")
    public init(sysctlPointer: UnsafePointer<SysctlPointerType>) {
        self.init(sysctlPointer: sysctlPointer, capacity: 1)
    }
}

extension SysctlValue where SysctlPointerType == Self {
    public init(sysctlPointer: UnsafePointer<SysctlPointerType>, capacity: Int) {
        assert(capacity == 1)
        self = sysctlPointer.pointee
    }

    public func withSysctlPointer<T>(do work: (UnsafePointer<SysctlPointerType>, Int) throws -> T) rethrows -> T {
        try withUnsafePointer(to: self) { try work($0, MemoryLayout<SysctlPointerType>.size) }
    }
}

extension String: SysctlValue {
    public typealias SysctlPointerType = CChar

    @inlinable
    public init(sysctlPointer: UnsafePointer<SysctlPointerType>, capacity: Int) {
        self.init(cString: sysctlPointer)
        assert(utf8.count + 1 == capacity) // + 1 => \0 at the end.
    }

    @inlinable
    public func withSysctlPointer<T>(do work: (UnsafePointer<SysctlPointerType>, Int) throws -> T) rethrows -> T {
        try withCString { try work($0, utf8.count) }
    }
}

extension CInt: SysctlValue {
    public typealias SysctlPointerType = Self
}

extension CLongLong: SysctlValue {
    public typealias SysctlPointerType = Self
}

extension timeval: SysctlValue {
    public typealias SysctlPointerType = Self
}

extension clockinfo: SysctlValue {
    public typealias SysctlPointerType = Self
}

extension loadavg: SysctlValue {
    public typealias SysctlPointerType = Self
}

extension kinfo_proc: SysctlValue {
    public typealias SysctlPointerType = Self
}

extension Array: SysctlValue where Element: SysctlValue {
    public typealias SysctlPointerType = Element.SysctlPointerType

    @inlinable
    public init(sysctlPointer: UnsafePointer<SysctlPointerType>, capacity: Int) {
        self = (0..<capacity).map {
            Element(sysctlPointer: sysctlPointer + $0, capacity: 1)
        }
    }

    @inlinable
    public func withSysctlPointer<T>(do work: (UnsafePointer<SysctlPointerType>, Int) throws -> T) rethrows -> T {
        let buffer = UnsafeMutableBufferPointer<SysctlPointerType>.allocate(capacity: count)
        defer { buffer.deallocate() }
        for (offset, element) in enumerated() {
            element.withSysctlPointer { ptr, size in
                buffer.initializeElement(at: offset, to: ptr.pointee)
            }
        }
        return try work(buffer.baseAddress!, buffer.count)
    }
}
