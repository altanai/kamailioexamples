# Kamailio Examples Repository

A comprehensive collection of Kamailio configurations and examples for various use cases and roles that Kamailio can serve.

Browsable version of this collection: **https://altanai.github.io/kamailioexamples/**

## Overview

This repository contains production-ready and example Kamailio configurations demonstrating:
- SIP protocol handling and routing
- User registration and location management
- Media proxy functionality
- NAT traversal
- WebRTC integration
- Load balancing and SBC (Session Border Controller) functionality
- Accounting and CDR handling
- TLS/SRTP security
- Lua scripting
- RTP media handling

**Note:** Examples are based on Kamailio v5.x. Many configurations have been updated from older wiki sources.

## Examples by Category

### Core SIP Features
- **[Barebone_SIPServer](Barebone_SIPServer/)** - Minimal SIP server with basic message handling, no relay/proxy/NAT
- **[REGISTER handle](REGISTER%20handle/)** - REGISTER request handling with 200 OK responses
- **[register_userlocation](register_userlocation/)** - User registration and USRLOC database management
- **[stateful_transaction_handle](stateful_transaction_handle/)** - Stateful transaction processing
- **[stateful_dialog_handle](stateful_dialog_handle/)** - Stateful dialog management
- **[Relay_with_flags](Relay_with_flags/)** - SIP message relay with flag-based routing
- **[record_routing](record_routing/)** - Record routing for sequential request handling
- **[Topology_hiding](Topology_hiding/)** - Topology hiding for privacy and security

### Routing & Proxying
- **[Loadbalancer_SIP_proxy](Loadbalancer_SIP_proxy/)** - Load balancing across multiple SIP endpoints
- **[edge_proxy](edge_proxy/)** - Edge proxy configuration for inter-domain routing
- **[Private_Ids](Private_Ids/)** - Private identity handling

### NAT & Media
- **[nat](nat/)** - NAT detection and traversal
- **[Lua_Nat_handle](Lua_Nat_handle/)** - Lua-based NAT handling with helper modules
- **[RTPProxy](RTPProxy/)** - RTPProxy media relay integration
- **[RTPEngine_media_proxy](RTPEngine_media_proxy/)** - RTPEngine media proxy handling
- **[rtpengine_bridge_on_fail](rtpengine_bridge_on_fail/)** - RTPEngine with fallback bridging

### WebRTC & Media Handling
- **[webrtc_to_webrtc_ws](webrtc_to_webrtc_ws/)** - WebRTC to WebRTC via WebSocket
- **[webrtc_to_webrtc_RTPengine](webrtc_to_webrtc_RTPengine/)** - WebRTC to WebRTC with RTPEngine media
- **[webrtc_to_sip_with_rtpengine](webrtc_to_sip_with_rtpengine/)** - WebRTC to SIP gateway with RTPEngine
- **[webrtc_to_sip_ipv4_ipv6_with_rtpengine](webrtc_to_sip_ipv4_ipv6_with_rtpengine/)** - IPv4/IPv6 dual-stack WebRTC to SIP
- **[psql_webrtc_rtpengine](psql_webrtc_rtpengine/)** - WebRTC with PostgreSQL and RTPEngine
- **[psql_webrtc_rtpproxy](psql_webrtc_rtpproxy/)** - WebRTC with PostgreSQL and RTPProxy

### Lua Scripting Examples
- **[Lua_kamailio_short](Lua_kamailio_short/)** - Minimal Lua scripting example
- **[Lua_load_balancer](Lua_load_balancer/)** - Load balancing logic in Lua
- **[Lua_sbc_with_auth](Lua_sbc_with_auth/)** - SBC with authentication in Lua
- **[Lua_sbc_with_auth_encryption](Lua_sbc_with_auth_encryption/)** - SBC with auth and encryption in Lua
- **[Lua_Registrar_permission_auth](Lua_Registrar_permission_auth/)** - Registrar with permission control in Lua
- **[Lua_RtpEngine_daisyChaining](Lua_RtpEngine_daisyChaining/)** - RTPEngine daisy chaining in Lua
- **[Lua_Rtpengine_MOS](Lua_Rtpengine_MOS/)** - MOS (Mean Opinion Score) calculation in Lua
- **[Lua_stateful_dialog_rtpengine](Lua_stateful_dialog_rtpengine/)** - Stateful dialog handling with RTPEngine in Lua
- **[Lua_dbsqlite](Lua_dbsqlite/)** - SQLite database integration in Lua

### Call Handling & Features
- **[forking](forking/)** - Parallel and serial call forking
- **[early_media_handle](early_media_handle/)** - Early media (183) handling
- **[accounting](accounting/)** - CDR and accounting configuration
- **[mos_cdr_accmodule](mos_cdr_accmodule/)** - MOS metrics with accounting module
- **[mos_rtpstats_rtpengine](mos_rtpstats_rtpengine/)** - RTP statistics and MOS with RTPEngine

### Database Integration
- **[mysql_user_stoarge](mysql_user_stoarge/)** - MySQL backend for user storage
- **[psql_location_storage](psql_location_storage/)** - PostgreSQL backend for location storage
- **[redis_db](redis_db/)** - Redis caching backend

### Advanced Features
- **[carrier](carrier/)** - Carrier routing configuration
- **[TLSonly](TLSonly/)** - TLS/SRTP security configuration
- **[sipcapture_siptrace_hep](sipcapture_siptrace_hep/)** - SIP capture and HEP protocol
- **[siptrace_homer_heplifyserver](siptrace_homer_heplifyserver/)** - SIP tracing with HOMER and Heplify
- **[jsonrpc_remoteprocesscalls](jsonrpc_remoteprocesscalls/)** - JSON-RPC remote procedure calls
- **[evapi_async_callcontrol](evapi_async_callcontrol/)** - Event API for async call control

### Testing Tools
- **[sipp](sipp/)** - SIPp test scenarios for load/stress testing

## TLS protocol method

Possible values are:
- TLSv1.2 - only TLSv1.2 connections are accepted (available starting with openssl/libssl v1.0.1e)
- TLSv1.1+ - TLSv1.1 or newer (TLSv1.2, ...) connections are accepted (available starting with openssl/libssl v1.0.1)
- TLSv1.1 - only TLSv1.1 connections are accepted (available starting with openssl/libssl v1.0.1)
- TLSv1+ - TLSv1.0 or newer (TLSv1.1, TLSv1.2, ...) connections are accepted.
- TLSv1 - only TLSv1 (TLSv1.0) connections are accepted. This is the default value.
- SSLv3 - only SSLv3 connections are accepted. Note: you shouldn't use SSLv3 for anything which should be secure.
- SSLv2 - only SSLv2 connections, for old clients. Note: you shouldn't use SSLv2 for anything which should be secure. Newer versions of libssl don't include support for it anymore.
- SSLv23 - any of the SSLv2, SSLv3 and TLSv1 or newer methods will be accepted.


Ref :
https://downloads2.goautodial.org/files/version4/etc/kamailio/kamailio-wss+sip.cfg
