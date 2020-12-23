public struct Network: SysctlNamespace {
    public typealias ParentNamespace = SysctlRootNamespace

    public static var sysctlNamePart: String { "net" }

    public struct IPv4: SysctlNamespace {
        public typealias ParentNamespace = Network

        public static var sysctlNamePart: String { "inet" }

        public struct ICMP: SysctlNamespace {
            public typealias ParentNamespace = IPv4

            public static var sysctlNamePart: String { "icmp" }

            public var answerBroadOrMulticastEchoRequests: Field<Bool> {
                get { "bmcastecho" }
                nonmutating set {}
            }

            public var answerNetworkMaskRequests: Field<Bool> {
                get { "maskrepl" }
                nonmutating set {}
            }
        }

        public var icmp: ICMP { .init() }
    }

    public var ipv4: IPv4 { .init() }
}

extension SysctlRootNamespace {
    public var network: Network { .init() }
}
