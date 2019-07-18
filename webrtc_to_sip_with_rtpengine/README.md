# Kamailio configuration supports Webrtc-> sip , sip->webrtc and webrtc-> webrtc

features 
- Register
- sanity checks
- auth
- location
- nat - detect and manage
- websocket and tls
- sdp modifcation
- rtpenine
- mysql
- presence - subscribe , notify


### SIP -> SIP

INVITE SDP

INVITE sip:altanai@106.51.78.22:19145;rinstance=c4b04a708c006af2 SIP/2.0.
Record-Route: <sip:34.200.245.139;lr=on>.
Via: SIP/2.0/UDP 34.200.245.139:5060;branch=z9hG4bK1c05.8d331bee61423445fbc620d8076cb89c.1.
Via: SIP/2.0/UDP 172.16.19.168:18956;received=106.51.78.22;branch=z9hG4bK-d8754z-ffb79d71712b1350-1---d8754z-;rport=53917.
Max-Forwards: 69.
Contact: <sip:altanai@106.51.78.22:53917;transport=udp;alias=106.51.78.22~53917~1>.
To: <sip:altanai@34.200.245.139>.
From: <sip:altanai@34.200.245.139>;tag=9d77522a.
Call-ID: ZjU2YjcwYjAyYzg3ZDQ5ZGU3MTFhOTgzZDRjMzEwOGI.
CSeq: 1 INVITE.
Allow: INVITE, ACK, CANCEL, OPTIONS, BYE, REFER, NOTIFY, MESSAGE, SUBSCRIBE, INFO.
Content-Type: application/sdp.
Supported: replaces.
User-Agent: Bria 3 release 3.5.5 stamp 71243.
Content-Length: 214.
.
v=0.
o=- 1563429687222998 1 IN IP4 172.16.19.168.
s=Bria 3 release 3.5.5 stamp 71243.
c=IN IP4 172.16.19.168.
t=0 0.
m=audio 50512 RTP/AVP 9 0 8 101.
a=rtpmap:101 telephone-event/8000.
a=fmtp:101 0-15.
a=sendrecv.




200 OK SDP

SIP/2.0 200 OK.
Via: SIP/2.0/UDP 172.16.19.168:18956;received=106.51.78.22;branch=z9hG4bK-d8754z-ffb79d71712b1350-1---d8754z-;rport=53917.
Record-Route: <sip:34.200.245.139;lr=on>.
Contact: <sip:altanai@106.51.78.22:19145;rinstance=c4b04a708c006af2>.
To: <sip:altanai@34.200.245.139>;tag=c33eb409.
From: <sip:altanai@34.200.245.139>;tag=9d77522a.
Call-ID: ZjU2YjcwYjAyYzg3ZDQ5ZGU3MTFhOTgzZDRjMzEwOGI.
CSeq: 1 INVITE.
Allow: OPTIONS, SUBSCRIBE, NOTIFY, INVITE, ACK, CANCEL, BYE, REFER, INFO.
Content-Type: application/sdp.
Supported: replaces.
User-Agent: X-Lite release 5.5.0 stamp 97576.
Content-Length: 204.
.
v=0.
o=- 1203463193 3 IN IP4 172.16.19.168.
s=X-Lite release 5.5.0 stamp 97576.
c=IN IP4 172.16.19.168.
t=0 0.
m=audio 60156 RTP/AVP 9 101.
a=rtpmap:101 telephone-event/8000.
a=fmtp:101 0-15.
a=sendrecv.


### SIP -> webrtc 



## Debug

Issues :  0(2707) ERROR: tls [tls_init.c:839]: tls_check_sockets(): TLSs<x.x.x.x:5061>: No listening socket found
 0(2707) ERROR: <core> [core/sr_module.c:898]: init_mod(): Error while initializing module tls (/usr/local/lib64/kamailio/modules/tls.so)
ERROR: error while initializing modules
CRITICAL: tls [tls_locking.c:103]: locking_f(): locking (callback): invalid lock number:  1 (range 0 - 0), called from err.c:375
 0(2673) ERROR: <core> [core/daemonize.c:303]: daemonize(): Main process exited before writing to pipe
Solution : check for lsietning socket address 


Issue :  tls_err_ret(): TLS accept:error:14094416:SSL routines:ssl3_read_bytes:sslv3 alert certificate unknown
tcp_read_req(): ERROR: tcp_read_req: error reading - c: 0x7ff63bb55e58 r: 0x7ff63bb55ed8 (-1)
Solution : In tls.cfg
```
[client:default]
verify_certificate = no
require_certificate = no
```
Can also changes the TLS methods to SSLv23 so that any of the SSLv2, SSLv3 and TLSv1 or newer methods will be accepted.


Ref :
TLS Module - https://kamailio.org/docs/modules/devel/modules/tls.html