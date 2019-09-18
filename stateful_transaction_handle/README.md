# SIP transactions Handling

SIP is a transaction protocol and transaction is sequence *one request and all its repsosnes* exchanged between SIP network elements.
Kamailio can behave as a stateful proxy ( transaction states not dialog states) through the TM module

## stateful vs stateless handling of trsansactions 

stateless - act like message forearders , stateless proxies do not take care of transactions.

stateful - entities usually create a state associated with a transaction that is kept in the memory for the duration of the transaction. 
extracts and aminains a unique transaction identifier and tried to match all incoming messages to associate with existing transactions
Branch parameter of Via header fields contains directly the transaction identifier. 

## stateful handling of new transactions 

Objective : 
It accepts all Register with 200 OK
Creates a new transaction
Due to a check for username altanai , cutom message hello is replied and  any other username is printed a diff rejection reply

Simulate local tarffic with sipp with username randomuser
```
sipp -sn uac 127.0.0.1:5060 -m 1 -s randomuser -trace_err -trace_msg
```
When condition matched 
```
2018-06-21  05:31:10:592  1561095070.592587: Aborting call on unexpected message for Call-Id '1-4064@127.0.1.1': while expecting '100' (index 1), received 'SIP/2.0 409 Well , hello altanai !
Via: SIP/2.0/UDP 127.0.1.1:5061;branch=z9hG4bK-4064-1-0;received=127.0.0.1
From: sipp <sip:sipp@127.0.1.1:5061>;tag=4064SIPpTag001
To: sut <sip:altanai@127.0.0.1:5060>;tag=a6a1c5f60faecf035a1ae5b6e96e979a-26ca
Call-ID: 1-4064@127.0.1.1
CSeq: 1 INVITE
Server: kamailio (5.1.8 (x86_64/linux))
Content-Length: 0
```
when condition on username doesnt match
```
2018-06-21  05:28:31:754  1561094911.754929: Aborting call on unexpected message for Call-Id '1-4004@127.0.1.1': while expecting '100' (index 1), received 'SIP/2.0 699 Do not proceed with this one
Via: SIP/2.0/UDP 127.0.1.1:5061;branch=z9hG4bK-4004-1-0;received=127.0.0.1
From: sipp <sip:sipp@127.0.1.1:5061>;tag=4004SIPpTag001
To: sut <sip:randomuser@127.0.0.1:5060>;tag=a6a1c5f60faecf035a1ae5b6e96e979a-894b
Call-ID: 1-4004@127.0.1.1
CSeq: 1 INVITE
Server: kamailio (5.1.8 (x86_64/linux))
Content-Length: 0
```

### Note : 
ACK is considered part of INVITE trasnaction when non 2xx / negative final resposne is recived , When 2xx final / positive response is recievd than ACK is not considered part of the transaction.


## Debugging 

**Issue1** relay methodINVITE
 1(26528) WARNING: sanity [sanity.c:233]: check_ruri_scheme(): failed to parse request uri [btpsh-5d7a2759-67a4-1@10.130.44.46]
 1(26528) CRITICAL: sl [../../core/ip_addr.h:455]: init_su(): unknown address family 0
 1(26528) CRITICAL: <core> [core/parser/../ip_addr.h:644]: ip_addr2sbuf(): unknown address family 0
 1(26528) CRITICAL: <core> [core/parser/../ip_addr.h:644]: ip_addr2sbuf(): unknown address family 0
 1(26528) ERROR: <core> [core/parser/parse_via.c:1324]: parse_via_param(): failure parsing via param
 1(26528) ERROR: <core> [core/parser/parse_via.c:2704]: parse_via(): parsing via on: <SIP/2.0/UDP 127.0.1.1:5077;received=
From: sipp  <sip:sipp@127.0.1.1:5077>;tag=26427SIPpTag011
To: : <sip:2222222222@zƒ>;tag=e9b4f21d
Call-ID: 99140ZDRlMjZiODJjZmJlZGMyZWEyMDM2OGIyZGRkZmNkOTQ
Cseq: 2 BYE
Server: fss
Content-Length: 0
 1(26528) ERROR: <core> [core/parser/parse_via.c:2708]: parse_via(): parse error, parsed so far:<SIP/2.0/UDP 127.0.1.1:5077;received=
 1(26528) ERROR: <core> [core/parser/msg_parser.c:125]: get_hdr_field(): bad via
 1(26528) ERROR: <core> [core/parser/msg_parser.c:331]: parse_headers(): bad header field [Via: SIP/2.0/UDP 127]
 1(26528) ERROR: <core> [core/parser/msg_parser.c:675]: parse_msg(): ERROR: parse_msg: message=<SIP/2.0 400 Bad Request URI
Via: SIP/2.0/UDP 127.0.1.1:5077;received=
From: sipp  <sip:sipp@127.0.1.1:5077>;tag=26427SIPpTag011
To: : <sip:2222222222@zz.z.z.z>;tag=e9b4f21d
Call-ID: 99140ZDRlMjZiODJjZmJlZGMyZWEyMDM2OGIyZGRkZmNkOTQ
Cseq: 2 BYE
Server: fss
Content-Length: 0
**solution** review the sipp xml of uas
Sample scipt whichs send BYE after reeiving INVITE and its ACK . Format of BYE to be sent from uas server should be as follows , 
```xml
<?xml version="1.0" encoding="UTF-8" ?>
<scenario name="Basic UAS responder">

<recv request="INVITE" crlf="true">

  <action>
   <!-- since we need to send a request to the remote part -->
   <!-- we need to extract the Contact and the From header content -->
   <ereg regexp=".*" search_in="hdr" header="From" assign_to="remote_from"/>
   <!-- assign the content of the Contaact SIP URI to the remote_contact var -->
   <!-- first var of assign_to contains the whole match -->
   <ereg regexp="sip:(.*)>.*" search_in="hdr" header="Contact" assign_to="trash,remote_contact"/>
  </action>
</recv>
 <Reference variables="trash"/>

<send retrans="500">
  <![CDATA[
  SIP/2.0 200 OK
  [last_Via:]
  [last_From:]
  [last_To:];tag=[pid]SIPpTag01[call_number]
  [last_Call-ID:]
  [last_CSeq:]
  Contact: <sip:[local_ip]:[local_port];transport=[transport]>
  Content-Type: application/sdp
  Content-Length: [len]
  
  v=0
  o=user1 53655765 2353687637 IN IP[local_ip_type] [local_ip]
  s=-
  c=IN IP[media_ip_type] [media_ip]
  t=0 0
  m=audio [media_port] RTP/AVP 0
  a=rtpmap:0 PCMU/8000
  ]]>
 </send>

 <recv request="ACK" crlf="true">
 </recv>

 <send retrans="500">
  <![CDATA[
  BYE [$remote_contact] SIP/2.0
  Via: SIP/2.0/[transport] [local_ip]:[local_port]
  From: sipp  <sip:sipp@[local_ip]:[local_port]>;tag=[pid]SIPpTag01[call_number]
  To: [$remote_from]
  Call-ID: [call_id]
  Cseq: 1 BYE
  Contact: sip:sipp@[local_ip]:[local_port]
  Content-Length: 0
  ]]>
 </send>

 <recv response="200">
 </recv>

<CallLengthRepartition value="10, 50, 100, 500, 1000, 5000, 10000"/>
</scenario>
```

**Issue2** 3(8846) CRITICAL: sl [../../core/ip_addr.h:455]: init_su(): unknown address family 0
 3(8846) CRITICAL: <core> [core/parser/../ip_addr.h:644]: ip_addr2sbuf(): unknown address family 0
 3(8846) CRITICAL: <core> [core/parser/../ip_addr.h:644]: ip_addr2sbuf(): unknown address family 0
 3(8846) ERROR: <core> [core/parser/parse_via.c:1324]: parse_via_param(): failure parsing via param
 **solution** set via params in UAS reposne
```
 [last_Via:]
```
 via param in UAS requests 
 ```
 Via: SIP/2.0/[transport] [local_ip]:[local_port]
 ```


