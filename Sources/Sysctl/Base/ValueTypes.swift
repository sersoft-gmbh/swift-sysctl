public import Darwin

/// Describes a type that can be read from / written to sysctl.
/// Usually, no new conformances to this protocol are necessary and the set of default conformances below will suffice.
public protocol SysctlValue {
    /// The underlyling type of the pointer read from / written to sysctl.
    associatedtype SysctlPointerType

#if compiler(>=6.2)
    /// Creates the type from a pointer read from sysctl.
    @safe
    init(sysctlPointer: UnsafePointer<SysctlPointerType>, capacity: Int)

    /// Creates the type from a pointer read from sysctl.
    @safe
    @available(*, deprecated, message: "Use initializer with capacity")
    init(sysctlPointer: UnsafePointer<SysctlPointerType>)

    /// Retrieves a pointer to write to sysctl. Note that the pointer should only be alive during the execution of `work`.
    /// - Parameter work: The closure during which the pointer should be alive. The second parameter should be the size of the pointer.
    @safe
    func withSysctlPointer<T>(do work: (UnsafePointer<SysctlPointerType>, Int) throws -> T) rethrows -> T
#else
    /// Creates the type from a pointer read from sysctl.
    init(sysctlPointer: UnsafePointer<SysctlPointerType>, capacity: Int)

    /// Creates the type from a pointer read from sysctl.
    @available(*, deprecated, message: "Use initializer with capacity")
    init(sysctlPointer: UnsafePointer<SysctlPointerType>)

    /// Retrieves a pointer to write to sysctl. Note that the pointer should only be alive during the execution of `work`.
    /// - Parameter work: The closure during which the pointer should be alive. The second parameter should be the size of the pointer.
    func withSysctlPointer<T>(do work: (UnsafePointer<SysctlPointerType>, Int) throws -> T) rethrows -> T
#endif
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
#if compiler(>=6.2)
        self = unsafe sysctlPointer.pointee
#else
        self = sysctlPointer.pointee
#endif
    }

    public func withSysctlPointer<T, E: Error>(do work: (UnsafePointer<SysctlPointerType>, Int) throws(E) -> T) throws(E) -> T {
#if compiler(>=6.2)
        unsafe try withUnsafePointer(to: self) { ptr throws(E) -> T in unsafe try work(ptr, MemoryLayout<SysctlPointerType>.size) }
#else
        try withUnsafePointer(to: self) { ptr throws(E) -> T in try work(ptr, MemoryLayout<SysctlPointerType>.size) }
#endif
    }
}

extension String: SysctlValue {
    public typealias SysctlPointerType = CChar

    @inlinable
    public init(sysctlPointer: UnsafePointer<SysctlPointerType>, capacity: Int) {
#if compiler(>=6.2)
        unsafe self.init(cString: sysctlPointer)
#else
        self.init(cString: sysctlPointer)
#endif
        assert(utf8.count + 1 == capacity) // + 1 => \0 at the end.
    }

    @inlinable
    public func withSysctlPointer<T>(do work: (UnsafePointer<SysctlPointerType>, Int) throws -> T) rethrows -> T {
#if compiler(>=6.2)
        unsafe try withCString { unsafe try work($0, utf8.count) }
#else
        try withCString { try work($0, utf8.count) }
#endif
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

#if compiler(>=6.2)
extension kinfo_proc: @unsafe SysctlValue {
    public typealias SysctlPointerType = Self
}
#else
extension kinfo_proc: SysctlValue {
    public typealias SysctlPointerType = Self
}
#endif

extension Array: SysctlValue where Element: SysctlValue {
    public typealias SysctlPointerType = Element.SysctlPointerType

    @inlinable
    public init(sysctlPointer: UnsafePointer<SysctlPointerType>, capacity: Int) {
        self = (0..<capacity).map {
#if compiler(>=6.2)
            unsafe Element(sysctlPointer: sysctlPointer + $0, capacity: 1)
#else
            Element(sysctlPointer: sysctlPointer + $0, capacity: 1)
#endif
        }
    }

    @inlinable
    public func withSysctlPointer<T, E: Error>(do work: (UnsafePointer<SysctlPointerType>, Int) throws(E) -> T) throws(E) -> T {
        let buffer = UnsafeMutableBufferPointer<SysctlPointerType>.allocate(capacity: count)
#if compiler(>=6.2)
        defer { unsafe buffer.deallocate() }
#else
        defer { buffer.deallocate() }
#endif
        for (offset, element) in enumerated() {
            element.withSysctlPointer { ptr, size in
#if compiler(>=6.2)
                unsafe buffer.initializeElement(at: offset, to: ptr.pointee)
#else
                buffer.initializeElement(at: offset, to: ptr.pointee)
#endif
            }
        }
#if compiler(>=6.2)
        return unsafe try work(buffer.baseAddress!, buffer.count)
#else
        return try work(buffer.baseAddress!, buffer.count)
#endif
    }
}
