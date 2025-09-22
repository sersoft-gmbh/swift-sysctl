internal import Darwin

@DebugDescription
struct SysctlError: Error, CustomStringConvertible {
    let target: (function: String, action: String)
    let sourceLocation: (file: StaticString, line: UInt)
    let errno: errno_t

#if compiler(>=6.2)
    var description: String {
        unsafe "\(target.function) failed \(target.action) (\(errno)): \(String(cString: strerror(errno)))!"
    }
#else
    var description: String {
        "\(target.function) failed \(target.action) (\(errno)): \(String(cString: strerror(errno)))!"
    }
#endif
}

extension Result where Failure == SysctlError {
    func requireSuccess() -> Success {
        switch self {
        case .success(let success): return success
        case .failure(let failure):
            fatalError(failure.description, file: failure.sourceLocation.file, line: failure.sourceLocation.line)
        }
    }
}

/// Runs `sysctl` returning the result.
/// Signature is copied from `sysctl` except for the `file` and `line` parameters.
func _sysctl(_ mib: UnsafeMutablePointer<Int32>,
             _ mibLength: u_int,
             _ oldptr: UnsafeMutableRawPointer?,
             _ oldlenptr: UnsafeMutablePointer<Int>?,
             _ newptr: UnsafeMutableRawPointer?,
             _ newlen: Int,
             file: StaticString = #file,
             line: UInt = #line) -> Result<Void, SysctlError> {
#if compiler(>=6.2)
    guard unsafe sysctl(mib, mibLength, oldptr, oldlenptr, newptr, newlen) != 0 else { return .success(()) }
    defer { errno = 0 }
    let mib = (0..<Int(mibLength)).reduce(Array(), { unsafe $0 + CollectionOfOne(mib[$1]) })
    let action = unsafe newptr != nil ? "writing" : "reading"
#else
    guard sysctl(mib, mibLength, oldptr, oldlenptr, newptr, newlen) != 0 else { return .success(()) }
    defer { errno = 0 }
    let mib = (0..<Int(mibLength)).reduce(Array(), { $0 + CollectionOfOne(mib[$1]) })
    let action = newptr != nil ? "writing" : "reading"
#endif
    return .failure(.init(target: ("sysctl", "when \(action) '\(mib.map(String.init).joined(separator: ","))'"),
                          sourceLocation: (file, line),
                          errno: errno))
}

/// Runs `sysctlbyname` returning the result.
/// Signature is copied from `sysctlbyname` except for the `file` and `line` parameters.
func _sysctlByName(_ name: UnsafePointer<CChar>,
                   _ oldptr: UnsafeMutableRawPointer?,
                   _ oldlenptr: UnsafeMutablePointer<Int>?,
                   _ newptr: UnsafeMutableRawPointer?,
                   _ newlen: Int,
                   file: StaticString = #file,
                   line: UInt = #line) -> Result<Void, SysctlError> {
#if compiler(>=6.2)
    guard unsafe sysctlbyname(name, oldptr, oldlenptr, newptr, newlen) != 0 else { return .success(()) }
    defer { errno = 0 }
    let action = unsafe "when \(newptr != nil ? "writing" : "reading") '\(String(cString: name))'"
#else
    guard sysctlbyname(name, oldptr, oldlenptr, newptr, newlen) != 0 else { return .success(()) }
    defer { errno = 0 }
    let action = "when \(newptr != nil ? "writing" : "reading") '\(String(cString: name))'"
#endif
    return .failure(.init(target: ("sysctlbyname", action),
                          sourceLocation: (file, line),
                          errno: errno))
}

/// Runs `sysctlnametomib` returning the result.
/// Signature is copied from `sysctlnametomib` except for the `file` and `line` parameters.
func _sysctlNameToMIB(_ name: UnsafePointer<CChar>,
                      _ mib: UnsafeMutablePointer<CInt>?,
                      _ miblen: UnsafeMutablePointer<Int>?,
                      file: StaticString = #file,
                      line: UInt = #line) -> Result<Void, SysctlError> {
#if compiler(>=6.2)
    guard unsafe sysctlnametomib(name, mib, miblen) != 0 else { return .success(()) }
    defer { errno = 0 }
    let action = unsafe "for name '\(String(cString: name))'"
#else
    guard sysctlnametomib(name, mib, miblen) != 0 else { return .success(()) }
    defer { errno = 0 }
    let action = "for name '\(String(cString: name))'"
#endif
    return .failure(.init(target: ("sysctlnametomib", action),
                          sourceLocation: (file, line),
                          errno: errno))
}
