# RTP engine integration with JSSIP

## RTPengine 

Multi threaded proxy for RTP traffic 
Full SDP parsing and rewriting
In-kernel packet forwarding for low-latency and low-CPU performance and automatic fallback to user space if kerna module is unavailale 



## https certs for jssip 

```
>openssl req -newkey rsa:2048 -new -nodes -x509 -days 3650 -keyout key.pem -out cert.pem
Generating a 2048 bit RSA private key
.+++
.........................................................................................+++
writing new private key to 'key.pem'
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) []:US
State or Province Name (full name) []:California
Locality Name (eg, city) []:FB 
Organization Name (eg, company) []:webrtc
Organizational Unit Name (eg, section) []:research
Common Name (eg, fully qualified host name) []:altanai
Email Address []:
```

## RTP Engine configuration 

**via-branch** - Used to additionally refine the matching logic between media streams and calls and call branches.

**SDES** -  we know that DTLS is used for encrypting data streams, while SRTP is used for encrypting media streams. SDES is a way for negotiating keys for SRTP. The keys are transported in the SDP attachment of a SIP message. 
default is to offer SDES without any session parameters when encryption is desired, and to accept it when DTLS-SRTP is unavailable. 

**DTLS** - influences the behaviour of DTLS-SRTP.
- off or no or disable
- passive : rtpengine should assume role of server for DTLS handshake

**ICE** - values cen be remove, force or force-relay. 
- remove :  any ICE attributes are stripped from the SDP body.  
- force, ICE attributes are first stripped, then new attributes are generated and inserted, which leaves the media proxy as the only ICE candidate. The default behavior (no ICE key present at all) is: if no ICE attributes are present, a new set is generated and the media proxy lists itself as ICE candidate; otherwise, the media proxy inserts itself as a low-priority candidate.
- force-relay, existing ICE candidates are left in place except relay type candidates, and rtpengine inserts itself as a relay candidate. It will also leave SDP c= and m= lines unchanged.

**transport protocol** - The transport protocol specified in the SDP body is to be rewritten to the string value given here.
options : RTP/AVP, RTP/AVPF, RTP/SAVP, RTP/SAVPF.
Arbitrary bridging between any of the supported RTP profiles (RTP/AVP, RTP/AVPF, RTP/SAVP, RTP/SAVPF)


**replace** - Controls which parts of the SDP body should be rewritten. Contains zero or more of:

origin - Replace the address found in the origin (o=) line of the SDP body. Corresponds to rtpproxy o flag.

session connection or session-connection - Replace the address found in the session-level connection (c=) line of the SDP body. Corresponds to rtpproxy c flag.

**flags** 

SIP source address

Ignore any IP addresses given in the SDP body and use the source address of the received SIP message (given in received from) as default endpoint address. This was the default behaviour of older versions of rtpengine and can still be made the default behaviour through the --sip-source CLI switch. Can be overridden through the media address key.

trust address

The opposite of SIP source address. This is the default behaviour unless the CLI switch --sip-source is active. Corresponds to the rtpproxy r flag. Can be overridden through the media address key.

symmetric - Corresponds to the rtpproxy w flag. Not used by rtpengine as this is the default, unless asymmetric is specified.

asymmetric - Corresponds to the rtpproxy a flag. Advertises an RTP endpoint which uses asymmetric RTP, which disables learning of endpoint addresses (see below).

unidirectional - When this flag is present, kernelize also one-way rtp media.

strict source - Normally, rtpengine attempts to learn the correct endpoint address for every stream during the first few seconds after signalling by observing the source address and port of incoming packets (unless asymmetric is specified). Afterwards, source address and port of incoming packets are normally ignored and packets are forwarded regardless of where they're coming from. With the strict source option set, rtpengine will continue to inspect the source address and port of incoming packets after the learning phase and compare them with the endpoint address that has been learned before. If there's a mismatch, the packet will be dropped and not forwarded.

media handover - Similar to the strict source option, but instead of dropping packets when the source address or port don't match, the endpoint address will be re-learned and moved to the new address. This allows endpoint addresses to change on the fly without going through signalling again. Note that this opens a security hole and potentially allows RTP streams to be hijacked, either partly or in whole.

reset - This causes rtpengine to un-learn certain aspects of the RTP endpoints involved, such as support for ICE or support for SRTP. For example, if ICE=force is given, then rtpengine will initially offer ICE to the remote endpoint. However, if a subsequent answer from that same endpoint indicates that it doesn't support ICE, then no more ICE offers will be made towards that endpoint, even if ICE=force is still specified. With the reset flag given, this aspect will be un-learned and rtpengine will again offer ICE to this endpoint. This flag is valid only in an offer message and is useful when the call has been transferred to a new endpoint without change of From or To tags.

port latching - Forces rtpengine to retain its local ports during a signalling exchange even when the remote endpoint changes its port.

record call - Identical to setting record call to on (see below).

no rtcp attribute - omit the a=rtcp line from the outgoing SDP.

full rtcp attribute - Include the full version of the a=rtcp line (complete with network address) instead of the short version with just the port number.

loop protect - Inserts a custom attribute (a=rtpengine:...) into the outgoing SDP to prevent rtpengine processing and rewriting the same SDP multiple times. 

always transcode  - skip the codec match-up routine and always trancode any received media to the first (highest priority) codec offered by the other side that is supported for transcoding. 

asymmetric codecs - in transcoding scenarios. By default, if an RTP client rejects a codec that was offered to it (by not including it in the answer SDP), rtpengine will assume that this client will also not send this codec (in addition to not wishing to receive it). With this flag given, rtpengine will not make this assumption, meaning that rtpengine will expect to potentially receive a codec from an RTP client even if that RTP client rejected this codec in its answer SDP.

The effective difference is that when rtpengine is instructed to offer a new codec for transcoding to an RTP client, and then this RTP client rejects this codec, by default rtpengine is then able to shut down its transcoding engine and revert to non-transcoding operation for this call. With this flag given however, rtpengine would not be able to shut down its transcoding engine in this case, resulting in potentially different media flow, and potentially transcoding media when it otherwise would not have to.

This flag should be given as part of the answer message.

all - Only relevant to the unblock media message. Instructs rtpengine to remove not only a full-call media block, but also remove directional media blocks that were imposed on individual participants.

pad crypto - RFC 4568 (section 6.1) is somewhat ambiguous regarding the base64 encoding format of a=crypto parameters added to an SDP body. The default interpretation is that trailing = characters used for padding should be omitted. With this flag set, these padding characters will be left in place.

generate mid - Add a=mid attributes to the outgoing SDP if they were not already present.

original sendrecv - With this flag present, rtpengine will leave the media direction attributes (sendrecv, recvonly, sendonly, and inactive) from the received SDP body unchanged. Normally rtpengine would consume these attributes and insert its own version of them based on other media parameters (e.g. a media section with a zero IP address would come out as sendonly or inactive).



## RTP/AVP vs RTP/SAVPF 

while RTP/AVP is plain RTP  , RTP/SAVPF is encrypted SRTP with RTCP feedback.

- For webrtc to webrtc call we add "generate-mid DTLS=passive SDES-off ICE=force" 

- For webrtc to sip call we add "rtcp-mux-demux DTLS=off SDES-off ICE=remove RTP/AVP"

- For sip to webrtc call we add "rtcp-mux-offer generate-mid DTLS=passive SDES-off ICE=force RTP/SAVPF"

## sip to sip call

altanai sends INVITE to bisht , dump for offer recived on rtpengine
```
{ "sdp": "v=0
o=- 1565587298544716 1 IN IP4 172.16.19.168
s=Bria 3 release 3.5.5 stamp 71243
c=IN IP4 172.16.19.168
t=0 0
m=audio 49198 RTP/AVP 123 9 8 0 101
a=rtpmap:123 opus/48000/2
a=fmtp:123 useinbandfec=1
a=rtpmap:101 telephone-event/8000
a=fmtp:101 0-15
a=sendrecv
", "replace": 
[ "origin", "session-connection" ], 
"call-id": "NmMxZDBjNmQyZmVlNTM3MDhiODdhYzA3ZDFkY2NmOWY", 
"via-branch": "z9hG4bK-d8754z-97dc0c42eee80a6d-1---d8754z-0", 
"received-from": [ "IP4", "111.93.146.206" ], 
"from-tag": "6efc8d0d", 
"command": "offer" }
```
rtpengine creates a news call , codec handler and timers. 
Codecs opus/48000 , G722/8000 , PCMA/8000 and PCMU/8000 are added , with telephone-event/8000
```
{ "sdp": "v=0
o=- 1565587298544716 1 IN IP4 172.31.90.251
s=Bria 3 release 3.5.5 stamp 71243
c=IN IP4 172.31.90.251
t=0 0
m=audio 10000 RTP/AVP 123 9 8 0 101
a=rtpmap:123 opus/48000/2
a=rtpmap:9 G722/8000
a=rtpmap:8 PCMA/8000
a=rtpmap:0 PCMU/8000
a=rtpmap:101 telephone-event/8000
a=fmtp:123 useinbandfec=1
a=fmtp:101 0-15
a=sendrecv
a=rtcp:10001
a=ice-ufrag:7ugULWyj
a=ice-pwd:KY77jksrL7wuU4I5n4dd4oAnJ9
a=candidate:CeXHaakxPVq2kpsc 1 UDP 2130706431 172.31.90.251 10000 typ host
a=candidate:AKb2HCvoaqgR9gEJ 1 UDP 2130706175 172.31.90.251 10016 typ host
a=candidate:CeXHaakxPVq2kpsc 2 UDP 2130706430 172.31.90.251 10001 typ host
a=candidate:AKb2HCvoaqgR9gEJ 2 UDP 2130706174 172.31.90.251 10017 typ host
", "result": "ok" }
```
as call is connectd by callee , rtpengine recives answer deump from rtpengine 
```
{ "sdp": "v=0
o=Z 0 2 IN IP4 192.168.2.166
s=Z
c=IN IP4 192.168.2.166
t=0 0
m=audio 44076 RTP/AVP 8 0 101
a=rtpmap:101 telephone-event/8000
a=fmtp:101 0-16
a=sendrecv
", "replace": [ "origin", "session-connection" ], 
"call-id": "NmMxZDBjNmQyZmVlNTM3MDhiODdhYzA3ZDFkY2NmOWY", 
"via-branch": "z9hG4bK-d8754z-97dc0c42eee80a6d-1---d8754z-0", 
"received-from": [ "IP4", "182.74.217.14" ], 
"from-tag": "6efc8d0d", 
"to-tag": "d84e9363", 
"command": "answer" }
```
rtp engine eliminates assymetric inbound/outbound codecs opus/48000/ and G722/8000
creates codec handler for PCMA/8000 , PCMU/8000 and telephone-event 8000
final answer SDP from rtpengine 
```
{ "sdp": "v=0
o=Z 0 2 IN IP4 172.31.90.251
s=Z
c=IN IP4 172.31.90.251
t=0 0
m=audio 10032 RTP/AVP 8 0 101
a=rtpmap:8 PCMA/8000
a=rtpmap:0 PCMU/8000
a=rtpmap:101 telephone-event/8000
a=fmtp:101 0-16
a=sendrecv
a=rtcp:10033
", "result": "ok" }
```

## webrtc to webrtc call 


Alice sends INVITE + SDP 

```
INVITE sip:john@3.218.143.160 SIP/2.0
Via: SIP/2.0/WSS p28j2fpp0pns.invalid;branch=z9hG4bK6336399
Max-Forwards: 69
To: <sip:john@3.218.143.160>
From: <sip:alice@3.218.143.160>;tag=a7690j0fn2
Call-ID: 1bk2ge4b737b0a07602k
CSeq: 7978 INVITE
Contact: <sip:alice@3.218.143.160;gr=urn:uuid:658cd889-e574-48a2-968c-9f8372fa4aaf>
Content-Type: application/sdp
Session-Expires: 90
Allow: INVITE,ACK,CANCEL,BYE,UPDATE,MESSAGE,OPTIONS,REFER,INFO
Supported: timer,gruu,ice,replaces,outbound
User-Agent: JsSIP 3.1.2
Content-Length: 1966

v=0
o=- 3584058318409525145 2 IN IP4 127.0.0.1
s=-
t=0 0
a=group:BUNDLE 0
a=msid-semantic: WMS 5013aSALpxpVCKOOP5JH08EWc5NnAyeadF1E
m=audio 7307 UDP/TLS/RTP/SAVPF 111 103 104 9 0 8 106 105 13 110 112 113 126
c=IN IP4 106.51.26.168
a=rtcp:9 IN IP4 0.0.0.0
a=candidate:3802297132 1 udp 2122260223 192.168.0.3 61924 typ host generation 0 network-id 1 network-cost 10
a=candidate:1274936569 1 udp 1686052607 106.51.26.168 7307 typ srflx raddr 192.168.0.3 rport 61924 generation 0 network-id 1 network-cost 10
a=candidate:2887880668 1 tcp 1518280447 192.168.0.3 9 typ host tcptype active generation 0 network-id 1 network-cost 10
a=ice-ufrag:jJmE
a=ice-pwd:M0YbtroY0RmwffhCDT1lInJH
a=ice-options:trickle
a=fingerprint:sha-256 60:5A:20:E7:1A:E8:28:41:96:51:FC:FF:06:64:4B:82:19:A7:BC:17:94:F7:5F:EB:05:46:F4:DF:82:19:E9:18
a=setup:actpass
a=mid:0
a=extmap:1 urn:ietf:params:rtp-hdrext:ssrc-audio-level
a=extmap:2 http://www.ietf.org/id/draft-holmer-rmcat-transport-wide-cc-extensions-01
a=extmap:3 urn:ietf:params:rtp-hdrext:sdes:mid
a=extmap:4 urn:ietf:params:rtp-hdrext:sdes:rtp-stream-id
a=extmap:5 urn:ietf:params:rtp-hdrext:sdes:repaired-rtp-stream-id
a=sendrecv
a=msid:5013aSALpxpVCKOOP5JH08EWc5NnAyeadF1E 2f151625-0d15-437a-b62b-ce1555287c94
a=rtcp-mux
a=rtpmap:111 opus/48000/2
a=rtcp-fb:111 transport-cc
a=fmtp:111 minptime=10;useinbandfec=1
a=rtpmap:103 ISAC/16000
a=rtpmap:104 ISAC/32000
a=rtpmap:9 G722/8000
a=rtpmap:0 PCMU/8000
a=rtpmap:8 PCMA/8000
a=rtpmap:106 CN/32000
a=rtpmap:105 CN/16000
a=rtpmap:13 CN/8000
a=rtpmap:110 telephone-event/48000
a=rtpmap:112 telephone-event/32000
a=rtpmap:113 telephone-event/16000
a=rtpmap:126 telephone-event/8000
a=ssrc:1957766036 cname:HAND+ubkFmMgNwtT
a=ssrc:1957766036 msid:5013aSALpxpVCKOOP5JH08EWc5NnAyeadF1E 2f151625-0d15-437a-b62b-ce1555287c94
a=ssrc:1957766036 mslabel:5013aSALpxpVCKOOP5JH08EWc5NnAyeadF1E
a=ssrc:1957766036 label:2f151625-0d15-437a-b62b-ce1555287c94
```

RTP engine offer recived 
```
Dump for 'offer' from 3.218.143.160:34894: { "sdp": "v=0
o=- 3584058318409525145 2 IN IP4 127.0.0.1
s=-
t=0 0
a=group:BUNDLE 0
a=msid-semantic: WMS 5013aSALpxpVCKOOP5JH08EWc5NnAyeadF1E
m=audio 7307 UDP/TLS/RTP/SAVPF 111 103 104 9 0 8 106 105 13 110 112 113 126
c=IN IP4 106.51.26.168
a=rtcp:9 IN IP4 0.0.0.0
a=candidate:3802297132 1 udp 2122260223 192.168.0.3 61924 typ host generation 0 network-id 1 network-cost 10
a=candidate:1274936569 1 udp 1686052607 106.51.26.168 7307 typ srflx raddr 192.168.0.3 rport 61924 generation 0 network-id 1 network-cost 10
a=candidate:2887880668 1 tcp 1518280447 192.168.0.3 9 typ host tcptype active generation 0 network-id 1 network-cost 10
a=ice-ufrag:jJmE
a=ice-pwd:M0YbtroY0RmwffhCDT1lInJH
a=ice-options:trickle
a=fingerprint:sha-256 60:5A:20:E7:1A:E8:28:41:96:51:FC:FF:06:64:4B:82:19:A7:BC:17:94:F7:5F:EB:05:46:F4:DF:82:19:E9:18
a=setup:actpass
a=mid:0
a=extmap:1 urn:ietf:params:rtp-hdrext:ssrc-audio-level
a=extmap:2 http://www.ietf.org/id/draft-holmer-rmcat-transport-wide-cc-extensions-01
a=extmap:3 urn:ietf:params:rtp-hdrext:sdes:mid
a=extmap:4 urn:ietf:params:rtp-hdrext:sdes:rtp-stream-id
a=extmap:5 urn:ietf:params:rtp-hdrext:sdes:repaired-rtp-stream-id
a=sendrecv
a=msid:5013aSALpxpVCKOOP5JH08EWc5NnAyeadF1E 2f151625-0d15-437a-b62b-ce1555287c94
a=rtcp-mux
a=rtpmap:111 opus/48000/2
a=rtcp-fb:111 transport-cc
a=fmtp:111 minptime=10;useinbandfec=1
a=rtpmap:103 ISAC/16000
a=rtpmap:104 ISAC/32000
a=rtpmap:9 G722/8000
a=rtpmap:0 PCMU/8000
a=rtpmap:8 PCMA/8000
a=rtpmap:106 CN/32000
a=rtpmap:105 CN/16000
a=rtpmap:13 CN/8000
a=rtpmap:110 telephone-event/48000
a=rtpmap:112 telephone-event/32000
a=rtpmap:113 telephone-event/16000
a=rtpmap:126 telephone-event/8000
a=ssrc:1957766036 cname:HAND+ubkFmMgNwtT
a=ssrc:1957766036 msid:5013aSALpxpVCKOOP5JH08EWc5NnAyeadF1E 2f151625-0d15-437a-b62b-ce1555287c94
a=ssrc:1957766036 mslabel:5013aSALpxpVCKOOP5JH08EWc5NnAyeadF1E
a=ssrc:1957766036 label:2f151625-0d15-437a-b62b-ce1555287c94
", 
"DTLS": "passive", 
"ICE": "force", 
"flags": [ "trust-address", "generate-mid" ], 
"replace": [ "origin", "session-connection" ], 
"SDES": [ "off" ], 
"call-id": "1bk2ge4b737b0a07602k", 
"via-branch": "z9hG4bK63363990", 
"received-from": [ "IP4", "106.51.26.168" ], 
"from-tag": "a7690j0fn2", 
"command": "offer" }
```
which it converts to 
```
Response dump for 'offer' to 3.218.143.160:34894: { "sdp": "v=0
o=- 3584058318409525145 2 IN IP4 172.31.90.251
s=-
t=0 0
a=msid-semantic: WMS 5013aSALpxpVCKOOP5JH08EWc5NnAyeadF1E
m=audio 10000 UDP/TLS/RTP/SAVPF 111 103 104 9 0 8 106 105 13 110 112 113 126
c=IN IP4 172.31.90.251
a=msid:5013aSALpxpVCKOOP5JH08EWc5NnAyeadF1E 2f151625-0d15-437a-b62b-ce1555287c94
a=rtcp-fb:111 transport-cc
a=ssrc:1957766036 cname:HAND+ubkFmMgNwtT
a=ssrc:1957766036 msid:5013aSALpxpVCKOOP5JH08EWc5NnAyeadF1E 2f151625-0d15-437a-b62b-ce1555287c94
a=ssrc:1957766036 mslabel:5013aSALpxpVCKOOP5JH08EWc5NnAyeadF1E
a=ssrc:1957766036 label:2f151625-0d15-437a-b62b-ce1555287c94
a=mid:0
a=rtpmap:111 opus/48000/2
a=rtpmap:103 ISAC/16000
a=rtpmap:104 ISAC/32000
a=rtpmap:9 G722/8000
a=rtpmap:0 PCMU/8000
a=rtpmap:8 PCMA/8000
a=rtpmap:106 CN/32000
a=rtpmap:105 CN/16000
a=rtpmap:13 CN/8000
a=rtpmap:110 telephone-event/48000
a=rtpmap:112 telephone-event/32000
a=rtpmap:113 telephone-event/16000
a=rtpmap:126 telephone-event/8000
a=fmtp:111 minptime=10;useinbandfec=1
a=sendrecv
a=rtcp:10001
a=rtcp-mux
a=setup:actpass
a=fingerprint:sha-1 4F:A6:94:9F:CD:77:C4:E9:CC:A9:69:60:8C:51:74:F5:0D:EC:1E:CA
a=ice-ufrag:2NTsD70T
a=ice-pwd:EUoaoJzkIB8vMoK1ya2LePGqMa
a=candidate:PoMOUEZaPBlsDKVx 1 UDP 2130706431 172.31.90.251 10000 typ host
a=candidate:EsdNXpjYcjXRXb3s 1 UDP 2130706175 172.31.90.251 10012 typ host
a=candidate:PoMOUEZaPBlsDKVx 2 UDP 2130706430 172.31.90.251 10001 typ host
a=candidate:EsdNXpjYcjXRXb3s 2 UDP 2130706174 172.31.90.251 10013 typ host
", "result": "ok" }
```
John recives INVITE + SDP
```
INVITE sip:9catqjnj@9el9oo04ue2t.invalid;transport=ws SIP/2.0
Record-Route: <sip:10.130.74.151:443;transport=ws;lr=on;nat=yes;rtp=bridge>
Via: SIP/2.0/WSS 10.130.74.151:443;branch=z9hG4bK0259.e76b1feed9df57643b76f853d9a3f39f.0
Via: SIP/2.0/WSS p28j2fpp0pns.invalid;rport=7296;received=106.51.26.168;branch=z9hG4bK6336399
Max-Forwards: 68
To: <sip:john@3.218.143.160>
From: <sip:alice@3.218.143.160>;tag=a7690j0fn2
Call-ID: 1bk2ge4b737b0a07602k
CSeq: 7978 INVITE
Contact: <sip:alice@3.218.143.160;gr=urn:uuid:658cd889-e574-48a2-968c-9f8372fa4aaf;alias=106.51.26.168~7296~6;alias=106.51.26.168~7296~6>
Content-Type: application/sdp
Session-Expires: 90
Allow: INVITE,ACK,CANCEL,BYE,UPDATE,MESSAGE,OPTIONS,REFER,INFO
Supported: timer,gruu,ice,replaces,outbound
User-Agent: JsSIP 3.1.2
Content-Length: 1503

v=0
o=- 3584058318409525145 2 IN IP4 172.31.90.251
s=-
t=0 0
a=msid-semantic: WMS 5013aSALpxpVCKOOP5JH08EWc5NnAyeadF1E
m=audio 10000 UDP/TLS/RTP/SAVPF 111 103 104 9 0 8 106 105 13 110 112 113 126
c=IN IP4 172.31.90.251
a=msid:5013aSALpxpVCKOOP5JH08EWc5NnAyeadF1E 2f151625-0d15-437a-b62b-ce1555287c94
a=rtcp-fb:111 transport-cc
a=ssrc:1957766036 cname:HAND+ubkFmMgNwtT
a=ssrc:1957766036 msid:5013aSALpxpVCKOOP5JH08EWc5NnAyeadF1E 2f151625-0d15-437a-b62b-ce1555287c94
a=ssrc:1957766036 mslabel:5013aSALpxpVCKOOP5JH08EWc5NnAyeadF1E
a=ssrc:1957766036 label:2f151625-0d15-437a-b62b-ce1555287c94
a=mid:0
a=rtpmap:111 opus/48000/2
a=rtpmap:103 ISAC/16000
a=rtpmap:104 ISAC/32000
a=rtpmap:9 G722/8000
a=rtpmap:0 PCMU/8000
a=rtpmap:8 PCMA/8000
a=rtpmap:106 CN/32000
a=rtpmap:105 CN/16000
a=rtpmap:13 CN/8000
a=rtpmap:110 telephone-event/48000
a=rtpmap:112 telephone-event/32000
a=rtpmap:113 telephone-event/16000
a=rtpmap:126 telephone-event/8000
a=fmtp:111 minptime=10;useinbandfec=1
a=sendrecv
a=rtcp:10001
a=rtcp-mux
a=setup:actpass
a=fingerprint:sha-1 4F:A6:94:9F:CD:77:C4:E9:CC:A9:69:60:8C:51:74:F5:0D:EC:1E:CA
a=ice-ufrag:2NTsD70T
a=ice-pwd:EUoaoJzkIB8vMoK1ya2LePGqMa
a=candidate:PoMOUEZaPBlsDKVx 1 UDP 2130706431 172.31.90.251 10000 typ host
a=candidate:EsdNXpjYcjXRXb3s 1 UDP 2130706175 172.31.90.251 10012 typ host
a=candidate:PoMOUEZaPBlsDKVx 2 UDP 2130706430 172.31.90.251 10001 typ host
a=candidate:EsdNXpjYcjXRXb3s 2 UDP 2130706174 172.31.90.251 10013 typ host
```




200 ok response + SDP send by John 
```
SIP/2.0 200 OK
Record-Route: <sip:10.130.74.151:443;transport=ws;lr=on;nat=yes;rtp=bridge>
Via: SIP/2.0/WSS 10.130.74.151:443;branch=z9hG4bK0259.e76b1feed9df57643b76f853d9a3f39f.0
Via: SIP/2.0/WSS p28j2fpp0pns.invalid;rport=7296;received=106.51.26.168;branch=z9hG4bK6336399
To: <sip:john@3.218.143.160>;tag=spot3c1845
From: <sip:alice@3.218.143.160>;tag=a7690j0fn2
Call-ID: 1bk2ge4b737b0a07602k
CSeq: 7978 INVITE
Contact: <sip:john@3.218.143.160;gr=urn:uuid:ac4e340e-6968-47cf-85dc-ff9869d10dc3>
Session-Expires: 90;refresher=uas
Supported: timer,gruu,ice,replaces,outbound
Content-Type: application/sdp
Content-Length: 1407

v=0
o=- 8769268052988187897 2 IN IP4 127.0.0.1
s=-
t=0 0
a=msid-semantic: WMS LACM347yLvTFGm92xwD87DWCquelhxolcvRX
m=audio 7311 UDP/TLS/RTP/SAVPF 111 103 104 9 0 8 106 105 13 110 112 113 126
c=IN IP4 106.51.26.168
a=rtcp:9 IN IP4 0.0.0.0
a=candidate:3802297132 1 udp 2122260223 192.168.0.3 53421 typ host generation 0 network-id 1 network-cost 10
a=candidate:1274936569 1 udp 1686052607 106.51.26.168 7311 typ srflx raddr 192.168.0.3 rport 53421 generation 0 network-id 1 network-cost 10
a=candidate:2887880668 1 tcp 1518280447 192.168.0.3 9 typ host tcptype active generation 0 network-id 1 network-cost 10
a=ice-ufrag:y51x
a=ice-pwd:zVp0RQj0/ZIjBn5+RPvShiJ6
a=ice-options:trickle
a=fingerprint:sha-256 17:A6:70:06:0B:65:1C:66:75:22:C3:6F:EE:9F:FA:5F:E2:08:AD:A6:BC:E5:23:CC:2F:1B:E7:E0:A9:C2:77:BC
a=setup:active
a=mid:0
a=sendrecv
a=msid:LACM347yLvTFGm92xwD87DWCquelhxolcvRX 97292b17-380a-4c48-9d69-273b8d79cb66
a=rtcp-mux
a=rtpmap:111 opus/48000/2
a=rtcp-fb:111 transport-cc
a=fmtp:111 minptime=10;useinbandfec=1
a=rtpmap:103 ISAC/16000
a=rtpmap:104 ISAC/32000
a=rtpmap:9 G722/8000
a=rtpmap:0 PCMU/8000
a=rtpmap:8 PCMA/8000
a=rtpmap:106 CN/32000
a=rtpmap:105 CN/16000
a=rtpmap:13 CN/8000
a=rtpmap:110 telephone-event/48000
a=rtpmap:112 telephone-event/32000
a=rtpmap:113 telephone-event/16000
a=rtpmap:126 telephone-event/8000
a=ssrc:196442935 cname:IhR+Hc3edjJrgFgO
```

RTPEngine recives answer 
```
Dump for 'answer' from 3.218.143.160:42996: { "sdp": "v=0
o=- 8769268052988187897 2 IN IP4 127.0.0.1
s=-
t=0 0
a=msid-semantic: WMS LACM347yLvTFGm92xwD87DWCquelhxolcvRX
m=audio 7311 UDP/TLS/RTP/SAVPF 111 103 104 9 0 8 106 105 13 110 112 113 126
c=IN IP4 106.51.26.168
a=rtcp:9 IN IP4 0.0.0.0
a=candidate:3802297132 1 udp 2122260223 192.168.0.3 53421 typ host generation 0 network-id 1 network-cost 10
a=candidate:1274936569 1 udp 1686052607 106.51.26.168 7311 typ srflx raddr 192.168.0.3 rport 53421 generation 0 network-id 1 network-cost 10
a=candidate:2887880668 1 tcp 1518280447 192.168.0.3 9 typ host tcptype active generation 0 network-id 1 network-cost 10
a=ice-ufrag:y51x
a=ice-pwd:zVp0RQj0/ZIjBn5+RPvShiJ6
a=ice-options:trickle
a=fingerprint:sha-256 17:A6:70:06:0B:65:1C:66:75:22:C3:6F:EE:9F:FA:5F:E2:08:AD:A6:BC:E5:23:CC:2F:1B:E7:E0:A9:C2:77:BC
a=setup:active
a=mid:0
a=sendrecv
a=msid:LACM347yLvTFGm92xwD87DWCquelhxolcvRX 97292b17-380a-4c48-9d69-273b8d79cb66
a=rtcp-mux
a=rtpmap:111 opus/48000/2
a=rtcp-fb:111 transport-cc
a=fmtp:111 minptime=10;useinbandfec=1
a=rtpmap:103 ISAC/16000
a=rtpmap:104 ISAC/32000
a=rtpmap:9 G722/8000
a=rtpmap:0 PCMU/8000
a=rtpmap:8 PCMA/8000
a=rtpmap:106 CN/32000
a=rtpmap:105 CN/16000
a=rtpmap:13 CN/8000
a=rtpmap:110 telephone-event/48000
a=rtpmap:112 telephone-event/32000
a=rtpmap:113 telephone-event/16000
a=rtpmap:126 telephone-event/8000
a=ssrc:196442935 cname:IhR+Hc3edjJrgFgO
", "DTLS": "passive", "ICE": "force", "flags": [ "trust-address", "generate-mid" ], "replace": [ "origin", "session-connection" ], "SDES": [ "off" ], "call-id": "1bk2ge4b737b0a07602k", "via-branch": "z9hG4bK63363990", "received-from": [ "IP4", "106.51.26.168" ], "from-tag": "a7690j0fn2", "to-tag": "spot3c1845", "command": "answer" }
```
and converts it into
```
Response dump for 'answer' to 3.218.143.160:42996: { "sdp": "v=0
o=- 8769268052988187897 2 IN IP4 172.31.90.251
s=-
t=0 0
a=msid-semantic: WMS LACM347yLvTFGm92xwD87DWCquelhxolcvRX
m=audio 10028 UDP/TLS/RTP/SAVPF 111 103 104 9 0 8 106 105 13 110 112 113 126
c=IN IP4 172.31.90.251
a=msid:LACM347yLvTFGm92xwD87DWCquelhxolcvRX 97292b17-380a-4c48-9d69-273b8d79cb66
a=rtcp-fb:111 transport-cc
a=ssrc:196442935 cname:IhR+Hc3edjJrgFgO
a=mid:0
a=rtpmap:111 opus/48000/2
a=rtpmap:103 ISAC/16000
a=rtpmap:104 ISAC/32000
a=rtpmap:9 G722/8000
a=rtpmap:0 PCMU/8000
a=rtpmap:8 PCMA/8000
a=rtpmap:106 CN/32000
a=rtpmap:105 CN/16000
a=rtpmap:13 CN/8000
a=rtpmap:110 telephone-event/48000
a=rtpmap:112 telephone-event/32000
a=rtpmap:113 telephone-event/16000
a=rtpmap:126 telephone-event/8000
a=fmtp:111 minptime=10;useinbandfec=1
a=sendrecv
a=rtcp:10028
a=rtcp-mux
a=setup:passive
a=fingerprint:sha-1 4F:A6:94:9F:CD:77:C4:E9:CC:A9:69:60:8C:51:74:F5:0D:EC:1E:CA
a=ice-ufrag:97En46C6
a=ice-pwd:DACzObKJFGw1S0FwQC1MSUjQP3
a=ice-options:trickle
a=candidate:PoMOUEZaPBlsDKVx 1 UDP 2130706431 172.31.90.251 10028 typ host
a=candidate:EsdNXpjYcjXRXb3s 1 UDP 2130706175 172.31.90.251 10036 typ host
a=end-of-candidates
", "result": "ok" }
```

Answer + SDP recived by Alice
```
SIP/2.0 200 OK
Record-Route: <sip:10.130.74.151:443;transport=ws;lr=on;nat=yes;rtp=bridge>
Via: SIP/2.0/WSS p28j2fpp0pns.invalid;rport=7296;received=106.51.26.168;branch=z9hG4bK6336399
To: <sip:john@3.218.143.160>;tag=spot3c1845
From: <sip:alice@3.218.143.160>;tag=a7690j0fn2
Call-ID: 1bk2ge4b737b0a07602k
CSeq: 7978 INVITE
Contact: <sip:john@3.218.143.160;gr=urn:uuid:ac4e340e-6968-47cf-85dc-ff9869d10dc3;alias=106.51.26.168~7303~6;alias=106.51.26.168~7303~6>
Session-Expires: 90;refresher=uas
Supported: timer,gruu,ice,replaces,outbound
Content-Type: application/sdp
Content-Length: 1170

v=0
o=- 8769268052988187897 2 IN IP4 172.31.90.251
s=-
t=0 0
a=msid-semantic: WMS LACM347yLvTFGm92xwD87DWCquelhxolcvRX
m=audio 10028 UDP/TLS/RTP/SAVPF 111 103 104 9 0 8 106 105 13 110 112 113 126
c=IN IP4 172.31.90.251
a=msid:LACM347yLvTFGm92xwD87DWCquelhxolcvRX 97292b17-380a-4c48-9d69-273b8d79cb66
a=rtcp-fb:111 transport-cc
a=ssrc:196442935 cname:IhR+Hc3edjJrgFgO
a=mid:0
a=rtpmap:111 opus/48000/2
a=rtpmap:103 ISAC/16000
a=rtpmap:104 ISAC/32000
a=rtpmap:9 G722/8000
a=rtpmap:0 PCMU/8000
a=rtpmap:8 PCMA/8000
a=rtpmap:106 CN/32000
a=rtpmap:105 CN/16000
a=rtpmap:13 CN/8000
a=rtpmap:110 telephone-event/48000
a=rtpmap:112 telephone-event/32000
a=rtpmap:113 telephone-event/16000
a=rtpmap:126 telephone-event/8000
a=fmtp:111 minptime=10;useinbandfec=1
a=sendrecv
a=rtcp:10028
a=rtcp-mux
a=setup:passive
a=fingerprint:sha-1 4F:A6:94:9F:CD:77:C4:E9:CC:A9:69:60:8C:51:74:F5:0D:EC:1E:CA
a=ice-ufrag:97En46C6
a=ice-pwd:DACzObKJFGw1S0FwQC1MSUjQP3
a=ice-options:trickle
a=candidate:PoMOUEZaPBlsDKVx 1 UDP 2130706431 172.31.90.251 10028 typ host
a=candidate:EsdNXpjYcjXRXb3s 1 UDP 2130706175 172.31.90.251 10036 typ host
a=end-of-candidates
```

## debug Help

**Issue 1** : 16(1899) ERROR: <core> [core/msg_translator.c:2003]: build_req_buf_from_sip_req(): could not create Via header
16(1899) ERROR: tm [t_fwd.c:476]: prepare_new_uac(): could not build request
**Solution** : 


*Ref :*

https://recordnotfound.com/rtpengine-sipwise-82321