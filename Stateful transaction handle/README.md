## stateful handling of new transactions 

Due to a check for username altanai , cutom message hello is replied and  any other username is printed a diff rejection reply
Simulate local tarffic with sipp with username randomuser
```
sipp -sn uac 127.0.0.1:5060 -m 1 -s randomuser -trace_err -trace_msg
```

```
2018-06-21	05:31:10:592	1561095070.592587: Aborting call on unexpected message for Call-Id '1-4064@127.0.1.1': while expecting '100' (index 1), received 'SIP/2.0 409 Well , hello altanai !
Via: SIP/2.0/UDP 127.0.1.1:5061;branch=z9hG4bK-4064-1-0;received=127.0.0.1
From: sipp <sip:sipp@127.0.1.1:5061>;tag=4064SIPpTag001
To: sut <sip:altanai@127.0.0.1:5060>;tag=a6a1c5f60faecf035a1ae5b6e96e979a-26ca
Call-ID: 1-4064@127.0.1.1
CSeq: 1 INVITE
Server: kamailio (5.1.8 (x86_64/linux))
Content-Length: 0
```

```
2018-06-21	05:28:31:754	1561094911.754929: Aborting call on unexpected message for Call-Id '1-4004@127.0.1.1': while expecting '100' (index 1), received 'SIP/2.0 699 Do not proceed with this one
Via: SIP/2.0/UDP 127.0.1.1:5061;branch=z9hG4bK-4004-1-0;received=127.0.0.1
From: sipp <sip:sipp@127.0.1.1:5061>;tag=4004SIPpTag001
To: sut <sip:randomuser@127.0.0.1:5060>;tag=a6a1c5f60faecf035a1ae5b6e96e979a-894b
Call-ID: 1-4004@127.0.1.1
CSeq: 1 INVITE
Server: kamailio (5.1.8 (x86_64/linux))
Content-Length: 0
```

