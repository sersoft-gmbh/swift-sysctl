#if swift(>=6.0)
internal import Darwin
#else
public import Darwin
#endif

struct SysctlError: Error, CustomStringConvertible {
    let target: (function: String, action: String)
    let sourceLocation: (file: StaticString, line: UInt)
    let errno: errno_t

    var description: String {
        "\(target.function) failed \(target.action) (\(errno)): \(String(cString: strerror(errno)))!"
    }
}

#if swift(>=6.0)
@DebugDescription
extension SysctlError {}
#endif

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
    guard sysctl(mib, mibLength, oldptr, oldlenptr, newptr, newlen) != 0 else { return .success(()) }
    defer { errno = 0 }
    let mib = (0..<Int(mibLength)).reduce(Array(), { $0 + CollectionOfOne(mib[$1]) })
    return .failure(.init(target: ("sysctl", "when \(newptr != nil ? "writing" : "reading") '\(mib.map(String.init).joined(separator: ","))'"),
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
    guard sysctlbyname(name, oldptr, oldlenptr, newptr, newlen) != 0 else { return .success(()) }
    defer { errno = 0 }
    return .failure(.init(target: ("sysctlbyname", "when \(newptr != nil ? "writing" : "reading") '\(String(cString: name))'"),
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
    guard sysctlnametomib(name, mib, miblen) != 0 else { return .success(()) }
    defer { errno = 0 }
    return .failure(.init(target: ("sysctlnametomib", "for name '\(String(cString: name))'"),
                          sourceLocation: (file, line),
                          errno: errno))
}
