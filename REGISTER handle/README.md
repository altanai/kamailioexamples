## Handle incoming REGISTER requests

sipp to send REGISTER
```
sipp -sf register.xml 127.0.0.1:5060 -m 1 -s altanai -trace_err -trace_msg 
```

sipp file for register.xml
```
<?xml version="1.0" encoding="ISO-8859-1" ?>
<!DOCTYPE scenario SYSTEM "sipp.dtd">

<scenario name="Basic REGISTER UAC">
  <send retrans="500">
    <![CDATA[
      REGISTER sip:[remote_ip]:[remote_port] SIP/2.0
      Via: SIP/2.0/[transport] [local_ip]:[local_port];branch=[branch]
      From: <sip:[service]@[remote_ip]>;tag=[pid]SIPpTag00[call_number]
      To: <sip:[service]@[remote_ip]>
      Call-ID: [call_id]
      CSeq: 1 REGISTER
      Contact: <sip:s@[local_ip]:[local_port]>
      Max-Forwards: 70
      Subject: Performance Test
      Content-Type: application/sdp
      Content-Length: [len]
    ]]>
  </send>

  <recv response="200" crlf="true">
  </recv>

  <!-- definition of the response time repartition table (unit is ms)   -->
  <ResponseTimeRepartition value="10, 20, 30, 40, 50, 100, 150, 200"/>

  <!-- definition of the call length repartition table (unit is ms)     -->
  <CallLengthRepartition value="10, 50, 100, 500, 1000, 5000, 10000"/>

</scenario>

```

to this kamailio responds as 
```
0(4217) DEBUG: <core> [core/udp_server.c:492]: udp_rcv_loop(): received on udp socket: (112/100/331) [[REGISTER sip:<pubip> SIP/2.0 0D  0A Via: SIP/2.0/UDP <uacip>:54761;branch=z9hG4bK188797224 0D  0A Ma]]
 0(4217) DEBUG: <core> [core/parser/msg_parser.c:604]: parse_msg(): SIP Request:
 0(4217) DEBUG: <core> [core/parser/msg_parser.c:606]: parse_msg():  method:  <REGISTER>
 0(4217) DEBUG: <core> [core/parser/msg_parser.c:608]: parse_msg():  uri:     <sip:publip>
 0(4217) DEBUG: <core> [core/parser/msg_parser.c:610]: parse_msg():  version: <SIP/2.0>
 0(4217) DEBUG: <core> [core/parser/parse_via.c:1303]: parse_via_param(): Found param type 232, <branch> = <z9hG4bK188797224>; state=16
 0(4217) DEBUG: <core> [core/parser/parse_via.c:2639]: parse_via(): end of header reached, state=5
 0(4217) DEBUG: <core> [core/parser/msg_parser.c:492]: parse_headers(): Via found, flags=2
 0(4217) DEBUG: <core> [core/parser/msg_parser.c:494]: parse_headers(): this is the first via
 0(4217) DEBUG: <core> [core/parser/parse_addr_spec.c:864]: parse_addr_spec(): end of header reached, state=10
 0(4217) DEBUG: <core> [core/parser/msg_parser.c:171]: get_hdr_field(): <To> [24]; uri=[sip:1494@pubip]
 0(4217) DEBUG: <core> [core/parser/msg_parser.c:172]: get_hdr_field(): to body [<sip:1494@pubip>
]
 0(4217) DEBUG: <core> [core/parser/msg_parser.c:152]: get_hdr_field(): cseq <CSeq>: <1> <REGISTER>
 0(4217) DEBUG: <core> [core/receive.c:213]: receive_msg(): --- received sip message - request - call-id: [901050394-1163004383-261746086] - cseq: [1 REGISTER]
 0(4217) DEBUG: <core> [core/receive.c:256]: receive_msg(): preparing to run routing scripts...
 0(4217) NOTICE: <script>: REGISTER received
 0(4217) NOTICE: <script>: request for other domain received
```