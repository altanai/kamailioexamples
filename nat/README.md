## NAT Handling by kamailio

NAT allows a single devices, such as a router or a MVNO device, to act as an agent between the Internet (populated with public IP addresses) and a private network (populated with private IP addresses). 

For a retail type cloud communication provider the do not bear a bundled private line or VPN connectivity to the customer premises who are almost certainly NAT'd. VOIP protocols like SIP , need persistent state and reachability for both outgoing and incoming calls. For this reason SIP includes ip and port ifnormation directly in sip messages 

**Symmetric NAT** not only translates the IP address from private to public (and vice versa), it also translates ports. 

**Interactive Connectivity Establishment (ICE)** 

**STUN (Session Traversal Utilities for NAT) server** allows clients to discover their public IP address and the type of NAT they are behind. 

For NAt handling following features must be added 

1. Ensure that transactional replies return to real source port – When an endpoint sends a request to your SIP server, normal behaviour is to forward replied to the transport protocol, address and port indicated in the topmost Via header of the request. 
In a NAT’d setting, this needs to be ignored and the reply must instead be returned to the real outside source address and port of the request. This is provided for by the rport parameter, as elaborated upon in RFC 3581. The trouble is, not all NAT’d endpoints include the ;rport parameter in their Via. Fortunately, there is a core Kamailio function, force_rport(), which tells Kamailio to treat the request as if ;rport were present.

2. Stay in the messaging path for the entire dialog life cycle – If Kamailio is providing far-end NAT traversal functionality for a call, it must continue to do so for the entire life cycle of the call accomplished by setting record_route() (rr module) for initial INVITE requests.

3. Fix Contact URI to be NAT-safe – This applies to requests and replies alike, and applied to INVITE and REGISTER transactions alike. 