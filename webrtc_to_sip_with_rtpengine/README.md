# Kamailio configuration supports Webrtc-> sip , sip->webrtc and webrtc-> webrtc

Features 
- Register
- sanity checks
- auth
- location
- nat - detect and manage
- websocket and tls
- sdp modification
- rtpengine
- mysql
- presence - subscribe , notify


## SIP -> SIP

A sip to sip call only involves RTP/AVP media streams , no transcoding or ICE is required 

**INVITE SDP**
```
INVITE sip:altanai@caller_ip:19145;rinstance=c4b04a708c006af2 SIP/2.0.
Record-Route: <sip:x.x.x.x;lr=on>.
Via: SIP/2.0/UDP x.x.x.x:5060;branch=z9hG4bK1c05.8d331bee61423445fbc620d8076cb89c.1.
Via: SIP/2.0/UDP x.x.x.x:18956;received=caller_ip;branch=z9hG4bK-d8754z-ffb79d71712b1350-1---d8754z-;rport=53917.
Max-Forwards: 69.
Contact: <sip:altanai@caller_ip:53917;transport=udp;alias=caller_ip~53917~1>.
To: <sip:altanai@x.x.x.x>.
From: <sip:altanai@x.x.x.x>;tag=9d77522a.
Call-ID: ZjU2YjcwYjAyYzg3ZDQ5ZGU3MTFhOTgzZDRjMzEwOGI.
CSeq: 1 INVITE.
Allow: INVITE, ACK, CANCEL, OPTIONS, BYE, REFER, NOTIFY, MESSAGE, SUBSCRIBE, INFO.
Content-Type: application/sdp.
Supported: replaces.
User-Agent: Bria 3 release 3.5.5 stamp 71243.
Content-Length: 214.
.
v=0.
o=- 1563429687222998 1 IN IP4 x.x.x.x.
s=Bria 3 release 3.5.5 stamp 71243.
c=IN IP4 x.x.x.x.
t=0 0.
m=audio 50512 RTP/AVP 9 0 8 101.
a=rtpmap:101 telephone-event/8000.
a=fmtp:101 0-15.
a=sendrecv.
```

**200 OK SDP**

As we can see the offeref SDP included 9-G722 , 0-PCMU , 8-PCMA and 101 telephone event , the reply only congains 9 and 101
```
SIP/2.0 200 OK.
Via: SIP/2.0/UDP x.x.x.x:18956;received=caller_ip;branch=z9hG4bK-d8754z-ffb79d71712b1350-1---d8754z-;rport=53917.
Record-Route: <sip:x.x.x.x;lr=on>.
Contact: <sip:altanai@caller_ip:19145;rinstance=c4b04a708c006af2>.
To: <sip:altanai@x.x.x.x>;tag=c33eb409.
From: <sip:altanai@x.x.x.x>;tag=9d77522a.
Call-ID: ZjU2YjcwYjAyYzg3ZDQ5ZGU3MTFhOTgzZDRjMzEwOGI.
CSeq: 1 INVITE.
Allow: OPTIONS, SUBSCRIBE, NOTIFY, INVITE, ACK, CANCEL, BYE, REFER, INFO.
Content-Type: application/sdp.
Supported: replaces.
User-Agent: X-Lite release 5.5.0 stamp 97576.
Content-Length: 204.
.
v=0.
o=- 1203463193 3 IN IP4 x.x.x.x.
s=X-Lite release 5.5.0 stamp 97576.
c=IN IP4 x.x.x.x.
t=0 0.
m=audio 60156 RTP/AVP 9 101.
a=rtpmap:101 telephone-event/8000.
a=fmtp:101 0-15.
a=sendrecv.
```

### RTP stream 

outgoing RTP packet 
```
Real-Time Transport Protocol
    [Stream setup by SDP (frame 419)]
    10.. .... = Version: RFC 1889 Version (2)
    ..0. .... = Padding: False
    ...0 .... = Extension: False
    .... 0000 = Contributing source identifiers count: 0
    0... .... = Marker: False
    Payload type: ITU-T G.711 PCMA (8)
    Sequence number: 141
    [Extended sequence number: 65677]
    Timestamp: 3020222685
    Synchronization Source identifier: 0x7afac841 (2063255617)
    Payload: f4f4f5cbcbc3dbdfd7505d5b454645474747445e5d505655...
```
incoming RTP packet
```
Real-Time Transport Protocol
    [Stream setup by SDP (frame 73)]
    10.. .... = Version: RFC 1889 Version (2)
    ..0. .... = Padding: False
    ...0 .... = Extension: False
    .... 0000 = Contributing source identifiers count: 0
    0... .... = Marker: False
    Payload type: ITU-T G.711 PCMA (8)
    Sequence number: 24400
    [Extended sequence number: 89936]
    Timestamp: 2456296383
    Synchronization Source identifier: 0x508dded1 (1351474897)
    Payload: c0c0c7c4d2dcdfd0d6d55f5e5254d7d4d5d5535c56575656...
```

### RTCP

```
Real-time Transport Control Protocol (Sender Report)
    [Stream setup by SDP (frame 419)]
    10.. .... = Version: RFC 1889 Version (2)
    ..0. .... = Padding: False
    ...0 0001 = Reception report count: 1
    Packet type: Sender Report (200)
    Length: 12 (52 bytes)
    Sender SSRC: 0x7afac841 (2063255617)
    Timestamp, MSW: 3774580039 (0xe0fb8547)
    Timestamp, LSW: 3774709317 (0xe0fd7e45)
    [MSW and LSW as NTP timestamp: Aug 12, 2019 06:27:19.878867999 UTC]
    RTP timestamp: 3020228150
    Sender's packet count: 142
    Sender's octet count: 22720
    Source 1
Real-time Transport Control Protocol (Source description)
    [Stream setup by SDP (frame 419)]
    10.. .... = Version: RFC 1889 Version (2)
    ..0. .... = Padding: False
    ...0 0001 = Source count: 1
    Packet type: Source description (202)
    Length: 6 (28 bytes)
    Chunk 1, SSRC/CSRC 0x7AFAC841
```

## SIP -> webrtc 

Offer with INVITE , proposing 8-PCMA and 0-PCMU which are specified in ITU-T Recommendation G.711. Other include 97 iLBC and 101 telephone-event. Also node that codec specific parameters are added to fmtp header
```
Dump for 'offer' from x.x.x.x:58280: 
{ 
"sdp": 
	"v=0
	o=Z 0 0 IN IP4 x.x.x.x
	s=Z
	c=IN IP4 x.x.x.x
	t=0 0
	m=audio 44076 RTP/AVP 97 101 8 0
	a=rtpmap:97 iLBC/8000
	a=fmtp:97 mode=20
	a=rtpmap:101 telephone-event/8000
	a=fmtp:101 0-16
	a=sendrecv", 
"DTLS": "passive", 
"ICE": "force", 
"flags": [ "generate-mid" ], 
"replace": [ "origin", "session-connection" ], 
"transport-protocol": "RTP/SAVPF", 
"rtcp-mux": [ "offer" ], 
"SDES": [ "off" ], 
"call-id": "5ojn2BUAQNNqxgBRSq4DLg..", 
"via-branch": "z9hG4bK-524287-1---c2f871b95bf7422b0", 
"received-from": [ "IP4", "x.x.x.x" ], 
"from-tag": "f706186c", 
"command": "offer" 
}
```
RTP engine processes it, adding rtcp-mux and ice candidates 
```
 Response dump for 'offer' to x.x.x.x:58280: 
{ 
"sdp": 
	"v=0
	o=Z 0 0 IN IP4 x.x.x.x
	s=Z
	c=IN IP4 x.x.x.x
	t=0 0m=audio 10210 RTP/SAVPF 97 101 8 0
	a=mid:1a=rtpmap:97 iLBC/8000
	a=rtpmap:101 telephone-event/8000
	a=rtpmap:8 PCMA/8000
	a=rtpmap:0 PCMU/8000
	a=fmtp:97 mode=20
	a=fmtp:101 0-16
	a=sendrecv
	a=rtcp:10211
	a=rtcp-mux
	a=setup:actpass
	a=fingerprint:sha-1 31:02:B2:35:5B:64:B2:7A:82:A8:5C:74:AE:BA:9C:31:50:72:1D:25
	a=ice-ufrag:oqrWXyzO
	a=ice-pwd:aeZz7aRvLYvLeiZEP9wvCuwXVBa=candidate:KJ7F9EsxS4CtrMjN 1 UDP 2130706431 x.x.x.x 10210 typ host
	a=candidate:KJ7F9EsxS4CtrMjN 2 UDP 2130706430 x.x.x.x 10211 typ host
", "result": "ok" }
```

Answer from webrtc endpoint
```
Dump for 'answer' from x.x.x.x:49575: 
{
"sdp": 
	"v=0o=- 7585402567789382279 2 IN IP4 127.0.0.1
	s=-
	t=0 0
	a=msid-semantic: WMS O3i5FJiELQy6FSW85j2dVrBn7ufkPudVtSFy
	m=audio 19273 RTP/SAVPF 101 8 0
	c=IN IP4 x.x.x.x
	a=rtcp:9 IN IP4 0.0.0.0
	a=candidate:2651777752 1 udp 2122260223 x.x.x.x 50914 typ host generation 0 network-id 1 network-cost 10
	a=candidate:524741740 1 udp 1686052607 x.x.x.x 19273 typ srflx raddr x.x.x.x rport 50914 generation 0 network-id 1 network-cost 10
	a=candidate:3498907176 1 tcp 1518280447 x.x.x.x 9 typ host tcptype active generation 0 network-id 1 network-cost 10
	a=ice-ufrag:xMuea=ice-pwd:M/R59kfKUI9QfYf/6l5YhGNQ
	a=ice-options:trickle
	a=fingerprint:sha-256 E7:F7:1B:E7:65:08:C5:88:29:74:7D:CC:BB:26:99:4B:11:A7:41:3D:A4:57:31:CA:56:EA:DE:D4:3D:EB:45:E4
	a=setup:active
	a=mid:1
	a=sendrecv
	a=msid:O3i5FJiELQy6FSW85j2dVrBn7ufkPudVtSFy 0844ac99-c80f-4c3e-bc34-ef2a143d5936
	a=rtcp-mux
	a=rtpmap:101 telephone-event/8000
	a=rtpmap:8 PCMA/8000
	a=rtpmap:0 PCMU/8000
	a=ssrc:2071600809 cname:fvXubSqOgFlmooMz
	a=ssrc:2071600809 msid:O3i5FJiELQy6FSW85j2dVrBn7ufkPudVtSFy 0844ac99-c80f-4c3e-bc34-ef2a143d5936
	a=ssrc:2071600809 mslabel:O3i5FJiELQy6FSW85j2dVrBn7ufkPudVtSFy
	a=ssrc:2071600809 label:0844ac99-c80f-4c3e-bc34-ef2a143d5936", 
"DTLS": "off", 
"ICE": "remove", 
"flags": [ "trust-address" ], 
"replace": [ "origin", "session-connection" ], 
"transport-protocol": "RTP/AVP", 
"rtcp-mux": [ "demux" ], 
"SDES": [ "off" ], 
"call-id": "5ojn2BUAQNNqxgBRSq4DLg..", 
"via-branch": "z9hG4bK-524287-1---c2f871b95bf7422b0", 
"received-from": [ "IP4", "x.x.x.x" ], 
"from-tag": "f706186c", 
"to-tag": "8fevqpird6", 
"command": "answer" 
}
```
After RTP engine processes it to forward to SIP endpoint
```
Response dump for 'answer' to x.x.x.x:49575: 
{ 
"sdp": 
	"v=0o=- 7585402567789382279 2 IN IP4 x.x.x.x
	s=-
	t=0 0
	a=msid-semantic: WMS O3i5FJiELQy6FSW85j2dVrBn7ufkPudVtSFy
	m=audio 10220 RTP/AVP 101 8 0
	c=IN IP4 x.x.x.x
	a=msid:O3i5FJiELQy6FSW85j2dVrBn7ufkPudVtSFy 0844ac99-c80f-4c3e-bc34-ef2a143d5936
	a=ssrc:2071600809 cname:fvXubSqOgFlmooMz
	a=ssrc:2071600809 msid:O3i5FJiELQy6FSW85j2dVrBn7ufkPudVtSFy 0844ac99-c80f-4c3e-bc34-ef2a143d5936
	a=ssrc:2071600809 mslabel:O3i5FJiELQy6FSW85j2dVrBn7ufkPudVtSFy
	a=ssrc:2071600809 label:0844ac99-c80f-4c3e-bc34-ef2a143d5936
	a=rtpmap:101 telephone-event/8000
	a=rtpmap:8 PCMA/8000
	a=rtpmap:0 PCMU/8000
	a=sendrecv
	a=rtcp:10221
", "result": "ok" }
```

ICE candidate pairing 
```
Learning new ICE candidate 2651777752:1
Created candidate pair KJ7F9EsxS4CtrMjN:2651777752:1 between x.x.x.x and x.x.x.x:50914, type host
Learning new ICE candidate 524741740:1
Created candidate pair KJ7F9EsxS4CtrMjN:524741740:1 between x.x.x.x and x.x.x.x:19273, type srflx
scheduling timer object at 1565592064.527508
Sending ICE/STUN request for candidate pair KJ7F9EsxS4CtrMjN:162950e33466580:1 from x.x.x.x to x.x.x.x:3017
...
Unknown STUN attribute: 0xc057
Triggering check for KJ7F9EsxS4CtrMjN:162950e33466580:1
scheduling timer object at 1565592064.471697
Successful STUN binding request from x.x.x.x:3017
...
Start nominating ICE pairs
Nominating ICE pair KJ7F9EsxS4CtrMjN:162950e33466580:1
scheduling timer object at 1565592064.852500
Sending nominating ICE/STUN request for candidate pair KJ7F9EsxS4CtrMjN:162950e33466580:1 from x.x.x.x to x.x.x.x:3017
scheduling timer object at 1565592064.772500

Processing incoming DTLS packet
DTLS: Peer certificate accepted
DTLS handshake successful
DTLS-SRTP successfully negotiated
SRTP keys, incoming:
--- AES_CM_128_HMAC_SHA1_80 key mRrsjBcF3t5AlC6lIG1BSw== salt PKnx9ngWM1M6Tcf+//g=
SRTP keys, outgoing:
--- AES_CM_128_HMAC_SHA1_80 key LLKN/M62ujEKKK2SMNSeuw== salt a4HZin/ule7P2uYricc=
DTLS-SRTP successfully negotiated
SRTP keys, incoming:
--- AES_CM_128_HMAC_SHA1_80 key mRrsjBcF3t5AlC6lIG1BSw== salt PKnx9ngWM1M6Tcf+//g=
SRTP keys, outgoing:
--- AES_CM_128_HMAC_SHA1_80 key LLKN/M62ujEKKK2SMNSeuw== salt a4HZin/ule7P2uYricc=
Sending DTLS packet
scheduling timer object at 1565592065.172636
Sending ICE/STUN request for candidate pair KJ7F9EsxS4CtrMjN:524741740:1 from x.x.x.x to x.x.x.x:19273
scheduling timer object at 1565592064.852500
RTP packet with unknown payload type 95 received
Forward to sink endpoint: x.x.x.x:19273 (RTP seq 5178 TS 3092375007)
```

### RTP stats for sip -> webrtc call

Final packet stats:
```
[ID="5ojn2BUAQNNqxgBRSq4DLg.."]: --- Tag 'f706186c', created 0:37 ago for branch '', in dialogue with '8fevqpird6'
[ID="5ojn2BUAQNNqxgBRSq4DLg.."]: ------ Media #1 (audio over RTP/AVP) using PCMA/8000
[ID="5ojn2BUAQNNqxgBRSq4DLg.."]: --------- Port   x.x.x.x:10220 <>   x.x.x.x:45310, SSRC bfe36b0, 1090 p, 187321 b, 1 e, 11 ts
[ID="5ojn2BUAQNNqxgBRSq4DLg.."]: freeing send_timer
[ID="5ojn2BUAQNNqxgBRSq4DLg.."]: --------- Port   x.x.x.x:10221 <>   x.x.x.x:28064 (RTCP), SSRC bfe36b0, 6 p, 368 b, 0 e, 11 ts
INFO: [ID="5ojn2BUAQNNqxgBRSq4DLg.."]: --- Tag '8fevqpird6', created 0:37 ago for branch 'z9hG4bK-524287-1---c2f871b95bf7422b0', in dialogue with 'f706186c'
INFO: [ID="5ojn2BUAQNNqxgBRSq4DLg.."]: ------ Media #1 (audio over RTP/SAVPF) using PCMA/8000
INFO: [ID="5ojn2BUAQNNqxgBRSq4DLg.."]: --------- Port   x.x.x.x:10210 <>    x.x.x.x:3017 , SSRC 7b7a1ea9, 1575 p, 268988 b, 0 e, 0 ts
INFO: [ID="5ojn2BUAQNNqxgBRSq4DLg.."]: --- SSRC bfe36b0
INFO: [ID="5ojn2BUAQNNqxgBRSq4DLg.."]: ------ Average MOS 4.1, lowest MOS 4.0 (at 0:15), highest MOS 4.3 (at 0:19)

ci=5ojn2BUAQNNqxgBRSq4DLg.., 
created_from=x.x.x.x:58280, 
last_signal=1565592067, 
tos=0, 

ml0_start_time=1565592060.357240, 
ml0_end_time=1565592097.369189, 
ml0_duration=37.011949, 
ml0_termination=REGULAR, 
ml0_local_tag=f706186c, 
ml0_local_tag_type=FROM_TAG, 
ml0_remote_tag=8fevqpird6, 
payload_type=8, 
ml0_midx1_rtp_endpoint_ip=x.x.x.x, 
ml0_midx1_rtp_endpoint_port=45310, 
ml0_midx1_rtp_local_relay_ip=x.x.x.x, 
ml0_midx1_rtp_local_relay_port=10220, 
ml0_midx1_rtp_relayed_packets=1090, 
ml0_midx1_rtp_relayed_bytes=187321, 
ml0_midx1_rtp_relayed_errors=1, 
ml0_midx1_rtp_last_packet=1565592086, 
ml0_midx1_rtp_in_tos_tclass=0, 
ml0_midx1_rtcp_endpoint_ip=x.x.x.x, 
ml0_midx1_rtcp_endpoint_port=28064, 
ml0_midx1_rtcp_local_relay_ip=x.x.x.x, 
ml0_midx1_rtcp_local_relay_port=10221, 
ml0_midx1_rtcp_relayed_packets=6, 
ml0_midx1_rtcp_relayed_bytes=368, 
ml0_midx1_rtcp_relayed_errors=0, 
ml0_midx1_rtcp_last_packet=1565592086, 
ml0_midx1_rtcp_in_tos_tclass=0, 

ml1_start_time=1565592067.943930, 
ml1_end_time=1565592097.369190, 
ml1_duration=29.425260, 
ml1_termination=REGULAR, 
ml1_local_tag=8fevqpird6, 
ml1_local_tag_type=TO_TAG, 
ml1_remote_tag=f706186c, 
payload_type=8, 
ml1_midx1_rtp_endpoint_ip=x.x.x.x, 
ml1_midx1_rtp_endpoint_port=3017, 
ml1_midx1_rtp_local_relay_ip=x.x.x.x, 
ml1_midx1_rtp_local_relay_port=10210, 
ml1_midx1_rtp_relayed_packets=1575, 
ml1_midx1_rtp_relayed_bytes=268988, 
ml1_midx1_rtp_relayed_errors=0, 
ml1_midx1_rtp_last_packet=1565592097, 
ml1_midx1_rtp_in_tos_tclass=0,
```

Stop the call 
```
Replying to 'delete' from x.x.x.x:49575 (elapsed time 0.000449 sec)
Response dump for 'delete' to x.x.x.x:49575: 
{ 
	"created": 1565592060, 
	"created_us": 343987, 
	"last signal": 1565592067, 
	"SSRC": { 
		"2071600809": {  }, 
		"201209520": { 
			"average MOS": { 
				"MOS": 41, 
				"round-trip time": 297329, 
				"jitter": 3, 
				"packet loss": 1, 
				"samples": 3 
			}, 
			"lowest MOS": { 
				"MOS": 40, 
				"round-trip time": 249450, 
				"jitter": 0, 
				"packet loss": 4, 
				"reported at": 1565592075 
			}, 
			"highest MOS": { 
				"MOS": 43, 
				"round-trip time": 261626, 
				"jitter": 1, 
				"packet loss": 0, 
				"reported at": 1565592079 }, 
				"MOS progression": { 
					"interval": 1, 
					"entries": [ 
						{ "MOS": 40, 
						"round-trip time": 249450, 
						"jitter": 0, 
						"packet loss": 4, 
						"reported at": 1565592075 
						}, 
						{ "MOS": 43, 
						"round-trip time": 261626, 
						"jitter": 1, 
						"packet loss": 0, 
						"reported at": 1565592079 
						}, 
						{ "MOS": 42, 
						"round-trip time": 380912, 
						"jitter": 8, 
						"packet loss": 0, 
						"reported at": 1565592085 
						} 
					] 
				} 
			} 
		}, 
		"tags": { 
			"8fevqpird6": { 
				"tag": "8fevqpird6", 
				"via-branch": "z9hG4bK-524287-1---c2f871b95bf7422b0", 
				"created": 1565592060, 
				"in dialogue with": "f706186c", 
				"medias": [ 
					{ "index": 1, 
					"type": "audio", 
					"protocol": "RTP/SAVPF", 
					"streams": [ 
						{ 
							"local port": 10210, 
							"endpoint": { "family": "IPv4", "address": "x.x.x.x", "port": 3017 }, 
							"advertised endpoint": { "family": "IPv4", "address": "x.x.x.x", "port": 19273 }, 
							"crypto suite": "AES_CM_128_HMAC_SHA1_80", "last packet": 1565592097, 
							"flags": [ "RTP", "RTCP", "filled", "confirmed", "kernelized", "no kernel support", "DTLS fingerprint verified", "ICE" ], 
							"SSRC": 2071600809, 
							"stats": { "packets": 1575, "bytes": 268988, "errors": 0 } 
						}, 
						{ "local port": 10211, "endpoint": {  }, 
							"advertised endpoint": {  }, 
							"crypto suite": "AES_CM_128_HMAC_SHA1_80", "last packet": 1565592060, 
							"flags": [ "RTCP", "fallback RTCP", "filled", "ICE" ], 
							"SSRC": 2071600809, 
							"stats": { "packets": 0, "bytes": 0, "errors": 0 } 
						} 
					], 
					"flags": [ "initialized", "send", "recv", "rtcp-mux", "DTLS-SRTP", "DTLS role passive", "ICE", "trickle ICE", "ICE 	controlling" ] 
					} 
				] 
			}, 
			"f706186c": { 
				"tag": "f706186c", 
				"created": 1565592060, 
				"in dialogue with": "8fevqpird6", 
				"medias": [ 
					{ "index": 1, 
					"type": "audio", 
					"protocol": "RTP/AVP", 
					"streams": [ 
						{ 
							"local port": 10220, 
							"endpoint": { "family": "IPv4", "address": "x.x.x.x", "port": 45310 }, 
							"advertised endpoint": { "family": "IPv4", "address": "x.x.x.x", "port": 44076 }, 
							"last packet": 1565592086, 
							"flags": [ "RTP", "filled", "confirmed", "kernelized", "no kernel support" ], 
							"SSRC": 201209520, 
							"stats": { "packets": 1090, "bytes": 187321, "errors": 1 } 
						}, 
						{ 
							"local port": 10221, 
							"endpoint": { "family": "IPv4", "address": "x.x.x.x", "port": 28064 }, 
							"advertised endpoint": { "family": "IPv4", "address": "x.x.x.x", "port": 44077 }, 
							"last packet": 1565592086, 
							"flags": [ "RTCP", "filled", "confirmed", "kernelized", "no kernel support" ], 
							"SSRC": 201209520, 
							"stats": { "packets": 6, "bytes": 368, "errors": 0 } 
						} 
					], 
					"flags": [ "initialized", "send", "recv" ] } 
				] 
			} 
		}, 
		"totals": { 
			"RTP": { "packets": 2665, "bytes": 456309, "errors": 1 }, 
			"RTCP": { "packets": 6, "bytes": 368, "errors": 0 } 
		}, 
"result": "ok" }
```

## Webrtc -> SIP

```
 Dump for 'offer' from 100.27.40.13:57865: 
 { 
 "sdp": 
 	"v=0
 	o=- 3701607994486821286 2 IN IP4 127.0.0.1
 	s=-t=0 0
 	a=group:BUNDLE 0
 	a=msid-semantic: WMS 9drULbj1uuoTAt9YfTwQpv6jIe7khmNxmmJV
 	m=audio 2398 UDP/TLS/RTP/SAVPF 111 103 104 9 0 8 106 105 13 110 112 113 126
 	c=IN IP4 x.x.x.x
 	a=rtcp:9 IN IP4 0.0.0.0
 	a=candidate:2651777752 1 udp 2122260223 x.x.x.x 53171 typ host generation 0 network-id 1 network-cost 10
 	a=candidate:3498907176 1 tcp 1518280447 x.x.x.x 9 typ host tcptype active generation 0 network-id 1 network-cost 10
 	a=candidate:524741740 1 udp 1686052607 x.x.x.x 2398 typ srflx raddr x.x.x.x rport 53171 generation 0 network-id 1 network-cost 10
 	a=ice-ufrag:KIrBa=ice-pwd:6G1UXaxa/ElknIVWjd8fJD06a=ice-options:tricklea=fingerprint:sha-256 7E:E1:B4:05:57:E8:84:98:59:A7:80:19:61:D8:C1:12:E3:55:B9:D9:EB:E1:AA:8F:D5:4E:A9:DE:25:23:C9:53
 	a=setup:actpass
 	a=mid:0
 	a=extmap:1 urn:ietf:params:rtp-hdrext:ssrc-audio-level
 	a=extmap:2 http://www.ietf.org/id/draft-holmer-rmcat-transport-wide-cc-extensions-01
 	a=extmap:3 urn:ietf:params:rtp-hdrext:sdes:mid
 	a=extmap:4 urn:ietf:params:rtp-hdrext:sdes:rtp-stream-ida=extmap:5 urn:ietf:params:rtp-hdrext:sdes:repaired-rtp-stream-id
 	a=sendrecv
 	a=msid:9drULbj1uuoTAt9YfTwQpv6jIe7khmNxmmJV eb58e859-31e8-4692-87cc-dd227840c367
 	a=rtcp-mux
 	a=rtpmap:111 opus/48000/2
 	a=rtcp-fb:111 transport-cc
 	a=fmtp:111 minptime=10;useinbandfec=1
 	a=rtpmap:103 ISAC/16000
 	a=rtpmap:104 ISAC/32000
 	a=rtpmap:9 G722/8000#0
	a=rtpmap:0 PCMU/8000
	a=rtpmap:8 PCMA/8000
	a=rtpmap:106 CN/32000
	a=rtpmap:105 CN/16000
	a=rtpmap:13 CN/8000
	a=rtpmap:110 telephone-event/48000
	a=rtpmap:112 telephone-event/32000
	a=rtpmap:113 telephone-event/16000
	a=rtpmap:126 telephone-event/8000
	a=ssrc:598828615 cname:XXVSBOK9mWpJCaF7
	a=ssrc:598828615 msid:9drULbj1uuoTAt9YfTwQpv6jIe7khmNxmmJV eb58e859-31e8-4692-87cc-dd227840c367
	a=ssrc:598828615 mslabel:9drULbj1uuoTAt9YfTwQpv6jIe7khmNxmmJV
	a=ssrc:598828615 label:eb58e859-31e8-4692-87cc-dd227840c367", 
"DTLS": "off", 
"ICE": "remove", 
"flags": [ "trust-address" ], 
"replace": [ "origin", "session-connection" ], 
"transport-protocol": "RTP/AVP", 
"rtcp-mux": [ "demux" ], 
"SDES": [ "off" ], 
"call-id": "idtgqcr6auruvdmpii3g", 
"via-branch": "z9hG4bK10571960", 
"received-from": [ "IP4", "x.x.x.x" ], 
"from-tag": "u2vt76nscl", 
"command": "offer" 
}
```
Offer for SIP endpoint after processinng
```
{ 
"sdp": 
	"v=0
	o=- 3701607994486821286 2 IN IP4 x.x.x.x
	s=-
	t=0 0
	a=msid-semantic: WMS 9drULbj1uuoTAt9YfTwQpv6jIe7khmNxmmJV
	m=audio 10242 RTP/AVP 111 103 104 9 0 8 106 105 13 110 112 113 126
	c=IN IP4 x.x.x.x
	a=msid:9drULbj1uuoTAt9YfTwQpv6jIe7khmNxmmJV eb58e859-31e8-4692-87cc-dd227840c367
	a=rtcp-fb:111 transport-cc
	a=ssrc:598828615 cname:XXVSBOK9mWpJCaF7
	a=ssrc:598828615 msid:9drULbj1uuoTAt9YfTwQpv6jIe7khmNxmmJV eb58e859-31e8-4692-87cc-dd227840c367
	a=ssrc:598828615 mslabel:9drULbj1uuoTAt9YfTwQpv6jIe7khmNxmmJV
	a=ssrc:598828615 label:eb58e859-31e8-4692-87cc-dd227840c367
	a=mid:0a=rtpmap:111 opus/48000/2
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
	a=sendrecva=rtcp:10243", 
"result": "ok"
}
```

**answer**

```
{ 
"sdp": 
	"v=0
	o=- 1565606530396499 3 IN IP4 x.x.x.x
	s=Bria 3 release 3.5.5 stamp 71243
	c=IN IP4 x.x.x.x
	t=0 0
	m=audio 60146 RTP/AVP 111 9 0 8 126
	a=rtpmap:111 opus/48000/2
	a=fmtp:111 useinbandfec=1
	a=rtpmap:126 telephone-event/8000
	a=fmtp:126 0-15
	a=sendrecv", 
"DTLS": "passive", 
"ICE": "force", 
"flags": [ "generate-mid" ], 
"replace": [ "origin", "session-connection" ], 
"transport-protocol": "RTP/SAVPF", 
"rtcp-mux": [ "offer" ], 
SDES": [ "off" ], 
"call-id": "idtgqcr6auruvdmpii3g", 
"via-branch": "z9hG4bK10571960", 
"received-from": [ "IP4", "x.x.x.x" ], 
"from-tag": "u2vt76nscl", 
"to-tag": "85941b2e", 
"command": "answer" 
}
```
Final asnwer dump afetr RTPengine's processing
```
{ 
"sdp": 
	"v=0
	o=- 1565606530396499 3 IN IP4 x.x.x.x
	s=Bria 3 release 3.5.5 stamp 71243
	c=IN IP4 x.x.x.xt=0 0
	m=audio 10262 RTP/SAVPF 111 9 0 8 126
	a=mid:0a=rtpmap:111 opus/48000/2
	a=rtpmap:9 G722/8000
	a=rtpmap:0 PCMU/8000
	a=rtpmap:8 PCMA/8000
	a=rtpmap:126 telephone-event/8000
	a=fmtp:111 useinbandfec=1
	a=fmtp:126 0-15
	a=sendrecv
	a=rtcp:10262
	a=rtcp-mux
	a=setup:passive
	a=fingerprint:sha-1 31:02:B2:35:5B:64:B2:7A:82:A8:5C:74:AE:BA:9C:31:50:72:1D:25
	a=ice-ufrag:cuLPfZNk
	a=ice-pwd:8NuoK05mpxck9v6oBRITQUwKIF
	a=ice-options:trickle
	a=candidate:KJ7F9EsxS4CtrMjN 1 UDP 2130706431 x.x.x.x 10262 typ host
	a=end-of-candidates", 
"result": "ok" 
}
```

### RTP stats 
```
[ID="idtgqcr6auruvdmpii3g"]: Final packet stats:
[ID="idtgqcr6auruvdmpii3g"]: --- Tag 'u2vt76nscl', created 0:50 ago for branch '', in dialogue with '85941b2e'
[ID="idtgqcr6auruvdmpii3g"]: ------ Media #1 (audio over RTP/SAVPF) using opus/48000/2
[ID="idtgqcr6auruvdmpii3g"]: --------- Port   172.31.90.251:10262 <>    x.x.x.x:41702, SSRC 23b16647, 2258 p, 202430 b, 0 e, 0 ts
Aug 12 10:42:56 ip-172-31-90-251 rtpengine[2092]: DEBUG: [ID="idtgqcr6auruvdmpii3g"]: freeing send_timer
[ID="idtgqcr6auruvdmpii3g"]: --- Tag '85941b2e', created 0:50 ago for branch 'z9hG4bK10571960', in dialogue with 'u2vt76nscl'
[ID="idtgqcr6auruvdmpii3g"]: ------ Media #1 (audio over RTP/AVP) using opus/48000/2
[ID="idtgqcr6auruvdmpii3g"]: --------- Port   172.31.90.251:10242 <>    x.x.x.x:45610, SSRC c596db34, 2282 p, 316985 b, 0 e, 0 ts
Aug 12 10:42:56 ip-172-31-90-251 rtpengine[2092]: DEBUG: [ID="idtgqcr6auruvdmpii3g"]: freeing send_timer
[ID="idtgqcr6auruvdmpii3g"]: --------- Port   172.31.90.251:10243 <>    x.x.x.x:45209 (RTCP), SSRC c596db34, 8 p, 616 b, 0 e, 5 ts
Aug 12 10:42:56 ip-172-31-90-251 rtpengine[2092]: DEBUG: [ID="idtgqcr6auruvdmpii3g"]: freeing send_timer
[ID="idtgqcr6auruvdmpii3g"]: --- SSRC c596db34
[ID="idtgqcr6auruvdmpii3g"]: ------ Average MOS 4.1, lowest MOS 4.1 (at 0:16), highest MOS 4.3 (at 0:11)
[ID="idtgqcr6auruvdmpii3g"]: --- SSRC 23b16647
[ID="idtgqcr6auruvdmpii3g"]: ------ Average MOS 4.1, lowest MOS 4.1 (at 0:13), highest MOS 4.1 (at 0:13)

Aug 12 10:42:56 ip-172-31-90-251 rtpengine[2092]: ci=idtgqcr6auruvdmpii3g, created_from=100.27.40.13:57865, last_signal=1565606530, tos=0, ml0_start_time=1565606526.329501, ml0_end_time=1565606576.431927, ml0_duration=50.102426, ml0_termination=REGULAR, ml0_local_tag=u2vt76nscl, ml0_local_tag_type=FROM_TAG, ml0_remote_tag=85941b2e, payload_type=111, ml0_midx1_rtp_endpoint_ip=x.x.x.x, ml0_midx1_rtp_endpoint_port=41702, ml0_midx1_rtp_local_relay_ip=172.31.90.251, ml0_midx1_rtp_local_relay_port=10262, ml0_midx1_rtp_relayed_packets=2258, ml0_midx1_rtp_relayed_bytes=202430, ml0_midx1_rtp_relayed_errors=0, ml0_midx1_rtp_last_packet=1565606576, ml0_midx1_rtp_in_tos_tclass=0, ml1_start_time=1565606530.620094, ml1_end_time=1565606576.431928, ml1_duration=45.811834, ml1_termination=REGULAR, ml1_local_tag=85941b2e, ml1_local_tag_type=TO_TAG, ml1_remote_tag=u2vt76nscl, payload_type=111, ml1_midx1_rtp_endpoint_ip=x.x.x.x, ml1_midx1_rtp_endpoint_port=45610, ml1_midx1_rtp_local_relay_ip=172.31.90.251, ml1_midx1_rtp_local_relay_port=10242, ml1_midx1_rtp_relayed_packets=2282, ml1_midx1_rtp_relayed_bytes=316985, ml1_midx1_rtp_relayed_errors=0, ml1_midx1_rtp_last_packet=1565606576, ml1_midx1_rtp_in_tos_tclass=0, ml1_midx1_rtcp_endpoint_ip=x.x.x.x, ml1_midx1_rtcp_endpoint_port=45209, ml1_midx1_rtcp_local_relay_ip=172.31.90.251, ml1_midx1_rtcp_local_relay_port=10243, ml1_midx1_rtcp_relayed_packets=8, ml1_midx1_rtcp_relayed_bytes=616, ml1_midx1_rtcp_relayed_errors=0, ml1_midx1_rtcp_last_packet=1565606571, ml1_midx1_rtcp_in_tos_tclass=0,
```


## Debug

**Issue 1** : TLS issues  
```
0(2707) ERROR: tls [tls_init.c:839]: tls_check_sockets(): TLSs<x.x.x.x:5061>: No listening socket found
 0(2707) ERROR: <core> [core/sr_module.c:898]: init_mod(): Error while initializing module tls (/usr/local/lib64/kamailio/modules/tls.so)
ERROR: error while initializing modules
CRITICAL: tls [tls_locking.c:103]: locking_f(): locking (callback): invalid lock number:  1 (range 0 - 0), called from err.c:375
 0(2673) ERROR: <core> [core/daemonize.c:303]: daemonize(): Main process exited before writing to pipe
```
\
**Solution** : check for listening socket address 

**Issue 2** :  tls_err_ret(): TLS accept:error:14094416:SSL routines:ssl3_read_bytes:sslv3 alert certificate unknown
tcp_read_req(): ERROR: tcp_read_req: error reading - c: 0x7ff63bb55e58 r: 0x7ff63bb55ed8 (-1)
\
**Solution** : In tls.cfg
```
[client:default]
verify_certificate = no
require_certificate = no
```
Can also changes the TLS methods to SSLv23 so that any of the SSLv2, SSLv3 and TLSv1 or newer methods will be accepted.

**Issue 3** : call between sip and webrtc endppints complain on SDES and DTLS-SRTP
JsSIP:ERROR:RTCSession emit "peerconnection:setremotedescriptionfailed" [error:DOMException: Failed to execute 'setRemoteDescription' on 'RTCPeerConnection': Failed to set remote offer sdp: SDES and DTLS-SRTP cannot be enabled at the same time.]
\
**Solution** : since Webrtc supports ICE/DTLS-SRTP while common sip endpoints like softphones bria , xlite , zoiper do not , we need to manage via rtpengine the briding and interconversion.
while calling from sip phone to webrtc endpoints , keep DTLS passive , off SDES and force ICE. Use RTP/AVP profile 
while calling from webrtc endpoint to sip phone , off DTLS and SDES and remove ICE . Use RTP/SAVPF profile

**Issue 4** :SRTP output wanted, but no crypto suite was negotiated
\
**Solution** --tbd

**Ref** :
- TLS Module - https://kamailio.org/docs/modules/devel/modules/tls.html