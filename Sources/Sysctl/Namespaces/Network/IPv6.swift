import Foundation

extension Networking {
    /// The namespace for IPv6 networking values (`inet6`).
    public struct IPv6: SysctlFullyQualifiedNamespace {
        public typealias ParentNamespace = Networking

        public static var namePart: String { "inet6" }
        public static var managementInformationBasePart: CInt { PF_INET6 }

        /// The namespace for IP (`ip6`) values inside the IPv6 networking namespace.
        public struct IP: SysctlNamespace {
            /// See SysctlNamespace
            public typealias ParentNamespace = IPv6

            /// See SysctlNamespace
            public static var namePart: String { "ip6" }

            /// Whether forwardings is enabled (`forwarding`).
            public var forwardingEnabled: Field<Bool> {
                get { .init(managementInformationBasePart: IPV6CTL_FORWARDING, namePart: "forwarding") }
                nonmutating set {}
            }
            /// Whether redirects are enabled (`redirect`).
            public var redirectsEnabled: Field<Bool> {
                get { .init(managementInformationBasePart: IPV6CTL_SENDREDIRECTS, namePart: "redirect") }
                nonmutating set {}
            }
        }

        /// The namespace for ICMP (`icmp6`) values inside the IPv6 networking namespace.
        public struct ICMP: SysctlNamespace {
            public typealias ParentNamespace = IPv6

            public static var namePart: String { "icmp6" }

            /// Whether to accept redirects (`rediraccept`).
            public var acceptRedirects: Field<Bool> {
                get { .init(managementInformationBasePart: ICMPV6CTL_REDIRACCEPT, namePart: "rediraccept") }
                nonmutating set {}
            }

            /// The timeout for redirects (`redirtimeout`).
            public var redirectTimeout: Field<CInt> {
                get { .init(managementInformationBasePart: ICMPV6CTL_REDIRTIMEOUT, namePart: "redirtimeout") }
                nonmutating set {}
            }
        }

        /// The IP (`ip6`) part.
        public var ip: IP { .init() }
        /// The ICMP (`icmp6`) part.
        public var icmp: ICMP { .init() }
    }

    /// The IPv6 part (`inet6`).
    public var ipv6: IPv6 { .init() }
}
