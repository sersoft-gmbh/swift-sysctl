/// Namespace for the hardware part (`hw`).
public struct Hardware: SysctlNamespace {
    /// See SysctlNamespace
    public typealias ParentNamespace = SysctlRootNamespace

    /// See SysctlNamespace
    public static var namePart: String { "hw" }

    /// The machine value (`machine`).
    public var machine: Field<String> { "machine" }
    /// The model value (`model`).
    public var model: Field<String> { "model" }

    /// The number of CPUs (`ncpu`).
    public var numberOfCPUs: Field<CInt> { "ncpu" }
    /// The user's number of physical cpus (`physicalcpu`).
    public var physicalCPUs: Field<CInt> { "physicalcpu" }
    
    /// The user's memory size (`memsize`) in bytes.
    public var memsize: Field<CLongLong>  { "memsize" }
}

extension SysctlRootNamespace {
    /// The hardware (`hw`) part.
    public var hardware: Hardware { .init() }
}
