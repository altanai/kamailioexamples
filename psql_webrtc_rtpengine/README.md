# PSQL for a Webrtc client on WS using RTPengine to relay media stream

Features 

- reqinit
- regsietr 
- user location 
- presence 
- psql stoarge
- xhttp and ws
- secure sip 5061
- tls via external tls.cfg
- rtpengine 
- rtcp mux
- nat detect and nat manage
- branch

Can support webrtc->webrtc , sip->webrtc , webrtc->sip

## TLS config 

file to soecify TLS parameters on a per role (server or client) and domain basis (for now only IPs)
Following params can be defined for each domain in tls config file

tls_method
verify_certificate
require_certificate
private_key
certificate
verify_depth
ca_list
crl
cipher_list
server_name

## debug TLS 

connect to the TLS server without any certificate validatio
```
openssl s_client -showcerts -debug -connect sip_server_ip:5061 -no_ssl2 -bugs
```

## RPC 


## RTPEngine 

```
rtpengine --interface=rtpengine_pub_ip --listen-ng=22222 --listen-cli=25062 --port-min=10000 --port-max=30000 --foreground --log-stderr --log-level=7
```
or specify all ports for tcp and udp 
```
rtpengine --interface=rtpengine_pub_ip --listen-ng=22222 --listen-tcp=25060 --listen-udp=2222 --port-min=10000 --port-max=30000 --foreground --log-stderr --log-level=7
```
Add delay for calls to be release after hangup
```
rtpengine -p /var/run/rtpengine.pid -i internal/rtpengine_pvt_ip -i external/rtpengine_pub_ip  --listen-ng=22222 --port-min=10000 --port-max=30000 -L 7 --delete-delay=0 -f -E
```

## RTP Offer answer and SDP exchange 

WebRTC Call from alice -> John 

**Alice's Invite + SDP**

Audio conists of UDP/TLS/RTP/SAVPF in offer SDP

```
INVITE sip:john@sip_server_ip SIP/2.0
Via: SIP/2.0/WSS 0b49k4u55gle.invalid;branch=z9hG4bK129082
Max-Forwards: 69
To: <sip:john@sip_server_ip>
From: <sip:alice@sip_server_ip>;tag=ufhj8jv9hg
Call-ID: ogi3dpopec8u56dffe3s
CSeq: 6468 INVITE
Contact: <sip:alice@sip_server_ip;gr=urn:uuid:c0c0ef67-28f4-4f99-84cf-4a50802706f9>
Content-Type: application/sdp
Session-Expires: 90
Allow: INVITE,ACK,CANCEL,BYE,UPDATE,MESSAGE,OPTIONS,REFER,INFO
Supported: timer,gruu,ice,replaces,outbound
User-Agent: JsSIP 3.1.2
Content-Length: 1822

v=0
o=- 789831103708242996 2 IN IP4 127.0.0.1
s=-
t=0 0
a=group:BUNDLE 0
a=msid-semantic: WMS LFYfHwNOw5Bz1FMVswSH66PueKArRgdmPUtI
m=audio 55215 UDP/TLS/RTP/SAVPF 111 103 104 9 0 8 106 105 13 110 112 113 126
c=IN IP4 x.x.x.x
a=rtcp:9 IN IP4 0.0.0.0
a=candidate:3802297132 1 udp 2122260223 x.x.x.x 55215 typ host generation 0 network-id 1 network-cost 10
a=candidate:2887880668 1 tcp 1518280447 x.x.x.x 9 typ host tcptype active generation 0 network-id 1 network-cost 10
a=ice-ufrag:T8N5
a=ice-pwd:3klni8BourXDKz/GXsWahQi7
a=ice-options:trickle
a=fingerprint:sha-256 B4:CB:0B:8B:B5:8C:85:CA:C9:87:F8:E3:92:0E:AD:80:B3:12:C4:81:1A:5D:C8:74:BC:B5:15:8B:FB:48:E4:15
a=setup:actpass
a=mid:0
a=extmap:1 urn:ietf:params:rtp-hdrext:ssrc-audio-level
a=extmap:2 http://www.ietf.org/id/draft-holmer-rmcat-transport-wide-cc-extensions-01
a=extmap:3 urn:ietf:params:rtp-hdrext:sdes:mid
a=extmap:4 urn:ietf:params:rtp-hdrext:sdes:rtp-stream-id
a=extmap:5 urn:ietf:params:rtp-hdrext:sdes:repaired-rtp-stream-id
a=sendrecv
a=msid:LFYfHwNOw5Bz1FMVswSH66PueKArRgdmPUtI 1f578b40-b2ee-46da-b731-d35a76a75e9d
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
a=ssrc:4290992267 cname:HEiBMwQq/O21A3jy
a=ssrc:4290992267 msid:LFYfHwNOw5Bz1FMVswSH66PueKArRgdmPUtI 1f578b40-b2ee-46da-b731-d35a76a75e9d
a=ssrc:4290992267 mslabel:LFYfHwNOw5Bz1FMVswSH66PueKArRgdmPUtI
a=ssrc:4290992267 label:1f578b40-b2ee-46da-b731-d35a76a75e9d
```

Consequently since tm module is loaded and it is INVITE with SDP, 
rtp_manage marks transaction with internal flag FL_SDP_BODY to know that the 1xx and 2xx are for rtpengine_answer()
```
rtpengine_manage("trust-address replace-origin replace-session-connection rtcp-mux-offer rtcp-mux-accept media-address=x.x.x.x record-call=on");
```

RTP engine offer 

```
Received command 'offer' from 127.0.0.1:58139
[1564587039.973766] NOTICE: [ogi3dpopec8u56dffe3s]: Creating new call
[d3:sdp1822:v=0
o=- 789831103708242996 2 IN IP4 127.0.0.1
s=-
t=0 0
a=group:BUNDLE 0
a=msid-semantic: WMS LFYfHwNOw5Bz1FMVswSH66PueKArRgdmPUtI
m=audio 55215 UDP/TLS/RTP/SAVPF 111 103 104 9 0 8 106 105 13 110 112 113 126
c=IN IP4 x.x.x.x
a=rtcp:9 IN IP4 0.0.0.0
a=candidate:3802297132 1 udp 2122260223 x.x.x.x 55215 typ host generation 0 network-id 1 network-cost 10
a=candidate:2887880668 1 tcp 1518280447 x.x.x.x 9 typ host tcptype active generation 0 network-id 1 network-cost 10
a=ice-ufrag:T8N5
a=ice-pwd:3klni8BourXDKz/GXsWahQi7
a=ice-options:trickle
a=fingerprint:sha-256 B4:CB:0B:8B:B5:8C:85:CA:C9:87:F8:E3:92:0E:AD:80:B3:12:C4:81:1A:5D:C8:74:BC:B5:15:8B:FB:48:E4:15
a=setup:actpass
a=mid:0
a=extmap:1 urn:ietf:params:rtp-hdrext:ssrc-audio-level
a=extmap:2 http://www.ietf.org/id/draft-holmer-rmcat-transport-wide-cc-extensions-01
a=extmap:3 urn:ietf:params:rtp-hdrext:sdes:mid
a=extmap:4 urn:ietf:params:rtp-hdrext:sdes:rtp-stream-id
a=extmap:5 urn:ietf:params:rtp-hdrext:sdes:repaired-rtp-stream-id
a=sendrecv
a=msid:LFYfHwNOw5Bz1FMVswSH66PueKArRgdmPUtI 1f578b40-b2ee-46da-b731-d35a76a75e9d
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
a=ssrc:4290992267 cname:HEiBMwQq/O21A3jy
a=ssrc:4290992267 msid:LFYfHwNOw5Bz1FMVswSH66PueKArRgdmPUtI 1f578b40-b2ee-46da-b731-d35a76a75e9d
a=ssrc:4290992267 mslabel:LFYfHwNOw5Bz1FMVswSH66PueKArRgdmPUtI
a=ssrc:4290992267 label:1f578b40-b2ee-46da-b731-d35a76a75e9d

13:media-address12:sip_server_ip11:record-call2:on5:flagsl13:trust-addresse7:replacel6:origin18:session-connectione8:rtcp-muxl5:offer6:accepte7:call-id20:ogi3dpopec8u56dffe3s13:received-froml3:IP413:x.x.x.xe8:from-tag10:ufhj8jv9hg7:command5:offere]
```


**John's 200 ok with SDP**

Here also audio is UDP/TLS/RTP/SAVPF

```
received text message:SIP/2.0 200 OK
Record-Route: <sip:rtpengine_pvt_ip:443;transport=ws;lr=on;nat=yes>
Via: SIP/2.0/WSS 0b49k4u55gle.invalid;rport=25143;received=x.x.x.x;branch=z9hG4bK129082
To: <sip:john@sip_server_ip>;tag=d1c13gjflf
From: <sip:alice@sip_server_ip>;tag=ufhj8jv9hg
Call-ID: ogi3dpopec8u56dffe3s
CSeq: 6468 INVITE
Contact: <sip:john@sip_server_ip;gr=urn:uuid:796a4fd4-fa25-4f39-ae15-b8f1beabf28b;alias=x.x.x.x~25529~6;alias=x.x.x.x~25529~6>
Session-Expires: 90;refresher=uas
Supported: timer,gruu,ice,replaces,outbound
Content-Type: application/sdp
Content-Length: 1477

v=0
o=- 8562992504752165544 2 IN IP4 127.0.0.1
s=-
t=0 0
a=group:BUNDLE 0
a=msid-semantic: WMS 1tD4KLVdpyXEDXZQP0Xot4XphEJME1DOnZPI
m=audio 52374 UDP/TLS/RTP/SAVPF 111 103 104 9 0 8 106 105 13 110 112 113 126
c=IN IP4 x.x.x.x
a=rtcp:9 IN IP4 0.0.0.0
a=candidate:3351850224 1 udp 2122260223 x.x.x.x 52374 typ host generation 0 network-id 1 network-cost 10
a=ice-ufrag:AF+x
a=ice-pwd:rEtt1iqqIC+u8mlOYA/ivYT6
a=ice-options:trickle
a=fingerprint:sha-256 45:CF:1D:A8:05:D5:23:A3:39:9C:40:FB:A5:AD:56:83:BF:ED:A7:B3:FE:D1:A5:5E:3D:70:DB:BC:43:28:0C:72
a=setup:active
a=mid:0
a=extmap:1 urn:ietf:params:rtp-hdrext:ssrc-audio-level
a=extmap:2 http://www.ietf.org/id/draft-holmer-rmcat-transport-wide-cc-extensions-01
a=extmap:3 urn:ietf:params:rtp-hdrext:sdes:mid
a=extmap:4 urn:ietf:params:rtp-hdrext:sdes:rtp-stream-id
a=extmap:5 urn:ietf:params:rtp-hdrext:sdes:repaired-rtp-stream-id
a=sendrecv
a=msid:1tD4KLVdpyXEDXZQP0Xot4XphEJME1DOnZPI 3a8ca772-316d-4601-b619-e8ffab77d329
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
a=ssrc:2974203233 cname:NVs2EOdtocOP4u6r
```

Rtpengine answer since its is a reply with SDP to INVITE having code 1xx and 2xx

```
Received command 'answer' from 127.0.0.1:56452
[d3:sdp1477:v=0
o=- 8562992504752165544 2 IN IP4 127.0.0.1
s=-
t=0 0
a=group:BUNDLE 0
a=msid-semantic: WMS 1tD4KLVdpyXEDXZQP0Xot4XphEJME1DOnZPI
m=audio 52374 UDP/TLS/RTP/SAVPF 111 103 104 9 0 8 106 105 13 110 112 113 126
c=IN IP4 x.x.x.x
a=rtcp:9 IN IP4 0.0.0.0
a=candidate:3351850224 1 udp 2122260223 x.x.x.x 52374 typ host generation 0 network-id 1 network-cost 10
a=ice-ufrag:AF+x
a=ice-pwd:rEtt1iqqIC+u8mlOYA/ivYT6
a=ice-options:trickle
a=fingerprint:sha-256 45:CF:1D:A8:05:D5:23:A3:39:9C:40:FB:A5:AD:56:83:BF:ED:A7:B3:FE:D1:A5:5E:3D:70:DB:BC:43:28:0C:72
a=setup:active
a=mid:0
a=extmap:1 urn:ietf:params:rtp-hdrext:ssrc-audio-level
a=extmap:2 http://www.ietf.org/id/draft-holmer-rmcat-transport-wide-cc-extensions-01
a=extmap:3 urn:ietf:params:rtp-hdrext:sdes:mid
a=extmap:4 urn:ietf:params:rtp-hdrext:sdes:rtp-stream-id
a=extmap:5 urn:ietf:params:rtp-hdrext:sdes:repaired-rtp-stream-id
a=sendrecv
a=msid:1tD4KLVdpyXEDXZQP0Xot4XphEJME1DOnZPI 3a8ca772-316d-4601-b619-e8ffab77d329
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
a=ssrc:2974203233 cname:NVs2EOdtocOP4u6r

13:media-address12:sip_server_ip11:record-call2:on5:flagsl13:trust-addresse7:replacel6:origin18:session-connectione8:rtcp-muxl5:offer6:accepte7:call-id20:ogi3dpopec8u56dffe3s13:received-froml3:IP413:x.x.x.xe8:from-tag10:ufhj8jv9hg6:to-tag10:d1c13gjflf7:command6:answere]
```

## debugging

**Issue 1** : via hedaer probelems
``` 
via_builder(): TCP/TLS connection (id: 0) for WebSocket could not be found
ERROR: <core> [core/msg_translator.c:2003]: build_req_buf_from_sip_req(): could not create Via header
ERROR: tm [t_fwd.c:476]: prepare_new_uac(): could not build request
```
**Solution** : check the local and advertised address and als othe reord record and via haders . If malformed use reord_route and loose_route functions 

**Issue 2** : Ran out of ports
```
ERROR: rtpengine [rtpengine.c:2474]: rtpp_function_call(): proxy replied with error: Ran out of ports
INFO: <script>: NATMANAGE is_request , doesnt have to tag, t_is_branch_route  thus first requst , add rr params  
U 127.0.0.1:22222 -> 127.0.0.1:35893
0_16011_12 d6:result5:error12:error-reason16:Ran out of portse
INFO: <script>: BRANCH FAILED: z9hG4bK5907631 + 012(16011) INFO: <script>: Failure: <null>
U 127.0.0.1:35893 -> 127.0.0.1:22222
0_16011_13 d7:call-id20:7cfuk85u3ajb64d8rf7m10:via-branch15:z9hG4bK5907631013:received-froml3:IP413:x.x.x.xe8:from-tag10:h1vt47m2se7:command6:deletee
U 127.0.0.1:22222 -> 127.0.0.1:35893
0_16011_13 d7:warning38:Call-ID not found or tags didn't match6:result2:oke
````

**Issues 3**: ERROR: rtpengine [rtpengine.c:2474]: rtpp_function_call(): proxy replied with error: Unknown call-id
**Solution** : -tbd

**Issue 4** : reording spool directory
```
[1564587039.973808] ERR: [ogi3dpopec8u56dffe3s]: Call recording requested, but no spool directory configured
```
**Solution** : -tbd

**Issue 5** :
```
ERR: [ogi3dpopec8u56dffe3s]: Failed to get 2 consecutive ports on all locals of logical 'default'
ERR: [ogi3dpopec8u56dffe3s]: Error allocating media ports
ERR: [ogi3dpopec8u56dffe3s]: Destroying call
INFO: [ogi3dpopec8u56dffe3s]: Final packet stats:
INFO: [ogi3dpopec8u56dffe3s]: --- Tag 'ufhj8jv9hg', created 0:00 ago for branch '', in dialogue with ''
INFO: [ogi3dpopec8u56dffe3s]: ------ Media #1 (audio over UDP/TLS/RTP/SAVPF) using unknown codec
INFO: [ogi3dpopec8u56dffe3s]: --- Tag '', created 0:00 ago for branch '', in dialogue with 'ufhj8jv9hg'
INFO: [ogi3dpopec8u56dffe3s]: ------ Media #1 (audio over UDP/TLS/RTP/SAVPF) using unknown codec
ERR: [ogi3dpopec8u56dffe3s]: Call start seems to exceed call stop
```
**Solution** : -tbd

**Issue 6** : interface 
```
[1564587040.078156] ERR: [ogi3dpopec8u56dffe3s]: Failed to get 2 consecutive ports on interface sip_server_ip for media relay (last error: Cannot assign requested address)
```
**Solution** : -tbd

**Issue7** : TCP/TLS connection (id: 0) for WebSocket could not be found and could not create Via header 
```
WARNING: <core> [core/msg_translator.c:2811]: via_builder(): TCP/TLS connection (id: 0) for WebSocket could not be found
ERROR: <core> [core/msg_translator.c:2003]: build_req_buf_from_sip_req(): could not create Via header
ERROR: tm [t_fwd.c:476]: prepare_new_uac(): could not build request
```
**Solution**:



Ref :
TLS module - https://kamailio.org/docs/modules/5.3.x/modules/tls.html#tls.p.tls_force_run
TLS debugging - https://www.kamailio.org/wiki/tutorials/tls/testing-and-debugging
