import Foundation

extension Networking {
    /// The namespace for IPv4 networking values (`inet`).
    public struct IPv4: SysctlNamespace {
        /// See SysctlNamespace
        public typealias ParentNamespace = Networking

        /// See SysctlNamespace
        public static var namePart: String { "inet" }

        /// The namespace for IP (`ip`) values inside the IPv4 networking namespace.
        public struct IP: SysctlNamespace {
            /// See SysctlNamespace
            public typealias ParentNamespace = IPv4

            /// See SysctlNamespace
            public static var namePart: String { "ip" }

            /// Whether forwardings is enabled (`forwarding`).
            public var forwardingEnabled: Field<Bool> {
                get { "forwarding" }
                nonmutating set {}
            }
            /// Whether redirects are enabled (`redirect`).
            public var redirectsEnabled: Field<Bool> {
                get { "redirect" }
                nonmutating set {}
            }
        }

        /// The namespace for ICMP (`icmp`) values inside the IPv4 networking namespace.
        public struct ICMP: SysctlNamespace {
            /// See SysctlNamespace
            public typealias ParentNamespace = IPv4
            /// See SysctlNamespace
            public static var namePart: String { "icmp" }

            /// Whether to answer broadcast and multicast echo requests (`bmcastecho`).
            public var answerBroadAndMulticastEchoRequests: Field<Bool> {
                get { "bmcastecho" }
                nonmutating set {}
            }

            /// Whether to answer network mask requests (`maskrepl`).
            public var answerNetworkMaskRequests: Field<Bool> {
                get { "maskrepl" }
                nonmutating set {}
            }
        }

        /// The IP (`ip`) part.
        public var ip: IP { .init() }
        /// The ICMP (`icmp`) part.
        public var icmp: ICMP { .init() }
    }

    /// The IPv4 part (`inet`).
    public var ipv4: IPv4 { .init() }
}
