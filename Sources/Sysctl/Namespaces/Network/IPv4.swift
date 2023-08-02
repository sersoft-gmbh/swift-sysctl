import Darwin
import Foundation

extension Networking {
    /// The namespace for IPv4 networking values (`inet`).
    public struct IPv4: SysctlFullyQualifiedNamespace {
        public typealias ParentNamespace = Networking

        public static var namePart: String { "inet" }
        public static var managementInformationBasePart: CInt { PF_INET }

        /// The namespace for IP (`ip`) values inside the IPv4 networking namespace.
        public struct IP: SysctlNamespace {
            public typealias ParentNamespace = IPv4

            public static var namePart: String { "ip" }

            /// Whether forwardings is enabled (`forwarding`).
            public var forwardingEnabled: Field<Bool> {
                get { .init(managementInformationBasePart: IPCTL_FORWARDING, namePart: "forwarding") }
                nonmutating set {}
            }
            /// Whether redirects are enabled (`redirect`).
            public var redirectsEnabled: Field<Bool> {
                get { .init(managementInformationBasePart: IPCTL_SENDREDIRECTS, namePart: "redirect") }
                nonmutating set {}
            }

            /// The maximum supported time-to-live (hop count) (`ttl`).
            public var timeToLive: Field<CInt> {
                get { .init(managementInformationBasePart: IPCTL_DEFTTL, namePart: "ttl") }
                nonmutating set {}
            }
        }

        /// The namespace for ICMP (`icmp`) values inside the IPv4 networking namespace.
        public struct ICMP: SysctlNamespace {
            public typealias ParentNamespace = IPv4

            public static var namePart: String { "icmp" }

            /// Whether to answer broadcast and multicast echo requests (`bmcastecho`).
            public var answerBroadAndMulticastEchoRequests: Field<Bool> {
                get { "bmcastecho" }
                nonmutating set {}
            }

#if os(macOS)
            /// Whether to answer network mask requests (`maskrepl`).
            public var answerNetworkMaskRequests: Field<Bool> {
                get { .init(managementInformationBasePart: ICMPCTL_MASKREPL, namePart: "maskrepl") }
                nonmutating set {}
            }
#endif
        }


        /// The namespace for UDP (`udp`) values inside the IPv4 networking namespace.
        public struct UDP: SysctlNamespace {
            public typealias ParentNamespace = IPv4

            public static var namePart: String { "udp" }

#if os(macOS)
            /// Whether to calculate checksums (`checksum`).
            public var checksumEnabled: Field<Bool> {
                get { .init(managementInformationBasePart: UDPCTL_CHECKSUM, namePart: "checksum") }
                nonmutating set {}
            }
#endif
        }

        /// The IP (`ip`) part.
        public var ip: IP { .init() }
        /// The ICMP (`icmp`) part.
        public var icmp: ICMP { .init() }
        /// The UDP (`udp`) part.
        public var udp: UDP { .init() }
    }

    /// The IPv4 part (`inet`).
    public var ipv4: IPv4 { .init() }
}
