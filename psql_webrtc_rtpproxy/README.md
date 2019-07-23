# PSQL Account storage for a Webrtc client on WS using RTPproxy to relay media stream

features :
	DB integration on postrgress for auth , location etc 
	RTP proxy 
	flood detection 
	presence 
	voice mail 
	pstn 
	msrp 
	xmlrpc  
	nathelper

## Flags to turn on 

  To run in debug mode: 
     - define WITH_DEBUG

  To enable mysql: 
     - define WITH_MYSQL

  To enable authentication execute:
     - enable mysql
     - define WITH_AUTH
     - add users using 'kamctl'

  To enable IP authentication execute:
     - enable mysql
     - enable authentication
     - define WITH_IPAUTH
     - add IP addresses with group id '1' to 'address' table

  To enable persistent user location execute:
     - enable mysql
     - define WITH_USRLOCDB

  To enable presence server execute:
     - enable mysql
     - define WITH_PRESENCE

  To enable nat traversal execute:
     - define WITH_NAT
     - install RTPProxy: http://www.rtpproxy.org
     - start RTPProxy:
        rtpproxy -l _your_public_ip_ -s udp:localhost:7722

  To enable PSTN gateway routing execute:
     - define WITH_PSTN
     - set the value of pstn.gw_ip
     - check route[PSTN] for regexp routing condition

  To enable database aliases lookup execute:
     - enable mysql
     - define WITH_ALIASDB

  To enable speed dial lookup execute:
     - enable mysql
     - define WITH_SPEEDDIAL

  To enable multi-domain support execute:
     - enable mysql
     - define WITH_MULTIDOMAIN

  To enable TLS support execute:
     - adjust CFGDIR/tls.cfg as needed
     - define WITH_TLS

  To enable XMLRPC support execute:
     - define WITH_XMLRPC
     - adjust route[XMLRPC] for access policy

  To enable anti-flood detection execute:
     - adjust pike and htable=>ipban settings as needed (default is
       block if more than 16 requests in 2 seconds and ban for 300 seconds)
     - define WITH_ANTIFLOOD

  To block 3XX redirect replies execute:
     - define WITH_BLOCK3XX

  To enable VoiceMail routing execute:
     - define WITH_VOICEMAIL
     - set the value of voicemail.srv_ip
     - adjust the value of voicemail.srv_port

  To enhance accounting execute:
     - enable mysql
     - define WITH_ACCDB
     - add following columns to database



Ref : https://gist.github.com/soufianeEL/514fb8fd9e26f8d18030