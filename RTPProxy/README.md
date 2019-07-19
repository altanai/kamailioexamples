# RTP Proxy for Kamailio acting as Proxy Server

traverse NAT firewalls
Relaying of RTP stream
Play of pre-encoded in-band announcements
RTP payload re-framing
Optimizing packet flow
Routing VoIP calls over VPN links
Real-time stream copying
tracks idle time for each existing session
multiple RTPProxy instances rcan provide fault-tolerance and load-balancing 

## Components of RTP proxy 

rtpproxy - main RTP proxy server binary (production build)
rtpproxy_debug - Main RTP proxy server binary (debug and profiling build)
makeann - Utility to pre-encode prompts and announcements (production build)
makeann_debug - Utility to pre-encode prompts and announcements (debug and profiling build)
extractaudio - Utility to convert recorded sessions into plain audio files (production build)
extractaudio_debug - Utility to convert recorded sessions into plain audio files (debug and profiling build)

## Principles of Operation

When SIP proxy receives an INVITE request, it extracts a call-id from it and hands it to the RTP proxy via Unix domain socket. 
The proxy then looks for an existing session with the same id. 
	-If the session exists, it returns a UDP port for that session. 
	-In case it doesn't exist, it creates a new session and binds it to a first empty UDP port from the range specified at the start time and returns the number of that port to a SIP proxy called it. 
Upon receiving a reply from the RTPproxy, SIP Proxy replaces media IP:port in the SDP body, in order to point to the media proxy and then it forwards a request as usual.

When SIP proxy received a non-negative SIP reply with the SDP body, it again extracts call-id from it and hands it to the rtpproxy. In this case the rtpproxy does not allocate a new session, if it doesn't exist. But simply performs a lookup among existing sessions and returns either a port number if the session is found, or an error code indicating that there is no session with such id. 

Once packet is received on RTPproxy which is listening, the proxy fills one of two ip:port structures associated with each call, using source ip:port of that packet as a value. When both structures are filled in, the proxy starts relaying UDP packets between call parties.

## Installation 

get code 
```
git clone -b master https://github.com/sippy/rtpproxy.git
git -C rtpproxy submodule update --init --recursive
```
compile and install
```
cd rtpproxy
     ./configure
     make clean all
     make install
```
Both prod and debug versionof proxy get installed 
check installed version
```
> rtpproxy -V
2.2.alpha.e6f1cf9
```
or 
```
> rtpproxy_debug -V
target_pfreq = 200.000000
2.2.alpha.e6f1cf9
```
or 
```
rtpproxy -v
Basic version: 20040107
Extension 20040107: Basic RTP proxy functionality
Extension 20050322: Support for multiple RTP streams and MOH
Extension 20060704: Support for extra parameter in the V command
Extension 20071116: Support for RTP re-packetization
Extension 20071218: Support for forking (copying) RTP stream
Extension 20080403: Support for RTP statistics querying
Extension 20081102: Support for setting codecs in the update/lookup command
Extension 20081224: Support for session timeout notifications
Extension 20090810: Support for automatic bridging
Extension 20140323: Support for tracking/reporting load
Extension 20140617: Support for anchoring session connect time
Extension 20141004: Support for extendable performance counters
Extension 20150330: Support for allocating a new port ("Un"/"Ln" commands)
Extension 20150420: Support for SEQ tracking and new rtpa_ counters; Q command extended
Extension 20150617: Support for the wildcard %%CC_SELF%% as a disconnect notify target
```

Run 
Note the rtpproxy cannot run as sudo so need to use and underprivellege suer , I am using defaukt ubuntu user 
run with denug mode
```
c -u ubuntu
target_pfreq = 200.000000
```
or start RTPProxy in prod mode with format rtpproxy -l _your_public_ip_ -s udp:localhost:7722
```
rtpproxy_debug -u ubuntu -l x.x.x.x -s udp:127.0.0.1:7722 -m 10000 -M 20000
```
check runnning processes
```
> ps -ef | grep rtpproxy
root     12407     1  0 06:18 ?        00:00:01 rtpproxy
root     12422     1  0 06:18 ?        00:00:00 rtpproxy_debug
root     12660     1  0 06:29 ?        00:00:00 rtpproxy_debug
ubuntu   12685     1  0 06:32 ?        00:00:00 rtpproxy_debug -u ubuntu
root     12695  2619  0 06:32 pts/1    00:00:00 grep --color=auto rtpproxy
```

## RTP proxy integration with kamailio SIP proxy 

```
# single rtproxy
modparam("rtpproxy", "rtpproxy_sock", "udp:localhost:12221")
```


## Debugging 

Issue : ERR:GLOBAL:create_twinlistener: can't bind to the IPv4 port 19566: Cannot assign requested address (99)
ERR:GLOBAL:rtpp_command_ul_handle: can't create listener on RTP prioxy 
or 
ERR:GLOBAL:create_twinlistener: can't bind to the IPv4 port 19566: Cannot assign requested address (99)
ERR:GLOBAL:rtpp_command_ul_handle: can't create listener on SIP proxy

Solution : 

## Features of this script 
No registeration or auth or user location DB storage 
directly handle incoming invite between with NAT
add RTP proxy for audio stream with NAT 

Ref:
This script is a much truncated and simplified version of kamailio script at https://github.com/kamailio/kamailio/blob/5.1/misc/examples/kemi/
RTP Proxy - https://www.rtpproxy.org/
RTP proxy Manual - https://www.rtpproxy.org/doc/master/user_manual.html
