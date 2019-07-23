# Record Routing

## To setup a call , use sipp UAS server


setup uas server on ip_addr on lets say port 5069
```
>sipp -sn uas -i 127.0.0.1 -p 5069
  Port   Total-time  Total-calls  Transport
  5069       0.00 s            0  UDP

  0 new calls during 0.000 s period      0 ms scheduler resolution
  0 calls                                Peak was 0 calls, after 0 s
  0 Running, 0 Paused, 0 Woken up
  0 dead call msg (discarded)          
  3 open sockets                        

                                 Messages  Retrans   Timeout   Unexpected-Msg
  ----------> INVITE             0         0         0         0        

  <---------- 180                0         0                            
  <---------- 200                0         0         0                  
  ----------> ACK         E-RTD1 0         0         0         0        

  ----------> BYE                0         0         0         0        
  <---------- 200                0         0                            
  [   4000ms] Pause              0                             0        
------------------------------ Sipp Server Mode -------------------------------
```

make call from sipphone which promptyly receives 100 Trying from kamailio

```
U UA_ipaddr:40410 -> kamailio_pvtipaddr:5060
INVITE sip:666@kamailio_ipaddr SIP/2.0.
Via: SIP/2.0/UDP UA_pvtipaddr:5068;branch=z9hG4bK-d8754z-c0b3686d19d94f7c-1---d8754z-;rport.
Max-Forwards: 70.
Contact: <sip:888@UA_pvtipaddr:5068>.
To: <sip:666@kamailio_ipaddr>.
From: <sip:888@kamailio_ipaddr>;tag=0fe95068.
Call-ID: M2Y5ZmUxYjhmNDE3NjAxZTAwNjJhM2JhMzcwOGQ3NGM.
CSeq: 1 INVITE.
Allow: INVITE, ACK, CANCEL, OPTIONS, BYE, REFER, NOTIFY, MESSAGE, SUBSCRIBE, INFO.
Content-Type: application/sdp.
Supported: replaces.
User-Agent: Bria 3 release 3.5.5 stamp 71243.
Content-Length: 286.
.
v=0.
o=- 1562059848963752 1 IN IP4 UA_pvtipaddr.
s=Bria 3 release 3.5.5 stamp 71243.
c=IN IP4 UA_pvtipaddr.
t=0 0.
m=audio 49430 RTP/AVP 9 0 18 98 101.
a=rtpmap:18 G729/8000.
a=fmtp:18 annexb=yes.
a=rtpmap:98 ILBC/8000.
a=rtpmap:101 telephone-event/8000.
a=fmtp:101 0-15.
a=sendrecv.


U kamailio_pvtipaddr:5060 -> UA_ipaddr:40410
SIP/2.0 100 trying -- your call is important to us.
Via: SIP/2.0/UDP UA_pvtipaddr:5068;branch=z9hG4bK-d8754z-c0b3686d19d94f7c-1---d8754z-;rport=40410;received=UA_ipaddr.
To: <sip:666@kamailio_ipaddr>.
From: <sip:888@kamailio_ipaddr>;tag=0fe95068.
Call-ID: M2Y5ZmUxYjhmNDE3NjAxZTAwNjJhM2JhMzcwOGQ3NGM.
CSeq: 1 INVITE.
Server: kamailio (5.1.8 (x86_64/linux)).
Content-Length: 0.

```

Invite is relayed to destination URI ie the sipp uas , which sends 180 riniging and 200 ok subsequently to kamailio
```
U kamailio_pvtipaddr:5060 -> 127.0.0.1:5069
INVITE sip:666@kamailio_ipaddr SIP/2.0.
Record-Route: <sip:kamailio_ipaddr;lr=on;ftag=0fe95068>.
Via: SIP/2.0/UDP kamailio_ipaddr:5060;branch=z9hG4bKe176.573cc8779c1db1a29a54642da0394bf5.0.
Via: SIP/2.0/UDP UA_pvtipaddr:5068;received=UA_ipaddr;branch=z9hG4bK-d8754z-c0b3686d19d94f7c-1---d8754z-;rport=40410.
Max-Forwards: 70.
Contact: <sip:888@UA_pvtipaddr:5068>.
To: <sip:666@kamailio_ipaddr>.
From: <sip:888@kamailio_ipaddr>;tag=0fe95068.
Call-ID: M2Y5ZmUxYjhmNDE3NjAxZTAwNjJhM2JhMzcwOGQ3NGM.
CSeq: 1 INVITE.
Allow: INVITE, ACK, CANCEL, OPTIONS, BYE, REFER, NOTIFY, MESSAGE, SUBSCRIBE, INFO.
Content-Type: application/sdp.
Supported: replaces.
User-Agent: Bria 3 release 3.5.5 stamp 71243.
Content-Length: 286.
.
v=0.
o=- 1562059848963752 1 IN IP4 UA_pvtipaddr.
s=Bria 3 release 3.5.5 stamp 71243.
c=IN IP4 UA_pvtipaddr.
t=0 0.
m=audio 49430 RTP/AVP 9 0 18 98 101.
a=rtpmap:18 G729/8000.
a=fmtp:18 annexb=yes.
a=rtpmap:98 ILBC/8000.
a=rtpmap:101 telephone-event/8000.
a=fmtp:101 0-15.
a=sendrecv.


U 127.0.0.1:5069 -> kamailio_pvtipaddr:5060
SIP/2.0 180 Ringing.
Via: SIP/2.0/UDP kamailio_ipaddr:5060;branch=z9hG4bKe176.573cc8779c1db1a29a54642da0394bf5.0, SIP/2.0/UDP UA_pvtipaddr:5068;received=UA_ipaddr;branch=z9hG4bK-d8754z-c0b3686d19d94f7c-1---d8754z-;rport=40410.
From: <sip:888@kamailio_ipaddr>;tag=0fe95068.
To: <sip:666@kamailio_ipaddr>;tag=9930SIPpTag012.
Call-ID: M2Y5ZmUxYjhmNDE3NjAxZTAwNjJhM2JhMzcwOGQ3NGM.
CSeq: 1 INVITE.
Contact: <sip:127.0.0.1:5069;transport=UDP>.
Content-Length: 0.
.

U 127.0.0.1:5069 -> kamailio_pvtipaddr:5060
SIP/2.0 200 OK.
Via: SIP/2.0/UDP kamailio_ipaddr:5060;branch=z9hG4bKe176.573cc8779c1db1a29a54642da0394bf5.0, SIP/2.0/UDP UA_pvtipaddr:5068;received=UA_ipaddr;branch=z9hG4bK-d8754z-c0b3686d19d94f7c-1---d8754z-;rport=40410.
From: <sip:888@kamailio_ipaddr>;tag=0fe95068.
To: <sip:666@kamailio_ipaddr>;tag=9930SIPpTag012.
Call-ID: M2Y5ZmUxYjhmNDE3NjAxZTAwNjJhM2JhMzcwOGQ3NGM.
CSeq: 1 INVITE.
Contact: <sip:127.0.0.1:5069;transport=UDP>.
Content-Type: application/sdp.
Content-Length:   129.
.
v=0.
o=user1 53655765 2353687637 IN IP4 127.0.0.1.
s=-.
c=IN IP4 127.0.0.1.
t=0 0.
m=audio 6000 RTP/AVP 0.
a=rtpmap:0 PCMU/8000.
```

from kamailio 200 ok is relayed back to caller on sipphone 
```
U kamailio_pvtipaddr:5060 -> UA_ipaddr:40410
SIP/2.0 200 OK.
Via: SIP/2.0/UDP UA_pvtipaddr:5068;received=UA_ipaddr;branch=z9hG4bK-d8754z-c0b3686d19d94f7c-1---d8754z-;rport=40410.
From: <sip:888@kamailio_ipaddr>;tag=0fe95068.
To: <sip:666@kamailio_ipaddr>;tag=9930SIPpTag012.
Call-ID: M2Y5ZmUxYjhmNDE3NjAxZTAwNjJhM2JhMzcwOGQ3NGM.
CSeq: 1 INVITE.
Contact: <sip:127.0.0.1:5069;transport=UDP>.
Content-Type: application/sdp.
Content-Length:   129.
.
v=0.
o=user1 53655765 2353687637 IN IP4 127.0.0.1.
s=-.
c=IN IP4 127.0.0.1.
t=0 0.
m=audio 6000 RTP/AVP 0.
a=rtpmap:0 PCMU/8000.
```

Call established
```
  0 new calls during 0.883 s period      1 ms scheduler resolution
  0 calls                                Peak was 1 calls, after 107 s
  0 Running, 2 Paused, 3 Woken up
  0 dead call msg (discarded)          
  3 open sockets                        

                                 Messages  Retrans   Timeout   Unexpected-Msg
  ----------> INVITE             2         0         0         0        

  <---------- 180                2         0                            
  <---------- 200                2         18        2                  
  ----------> ACK         E-RTD1 0         0         0         0        

  ----------> BYE                0         0         0         0        
  <---------- 200                0         0                            
  [   4000ms] Pause              0                             0        
------------------------------ Test Terminated --------------------------------
```