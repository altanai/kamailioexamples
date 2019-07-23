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
openssl s_client -showcerts -debug -connect 83.136.32.159:5061 -no_ssl2 -bugs
```

## RPC 

Ref :
TLS module - https://kamailio.org/docs/modules/5.3.x/modules/tls.html#tls.p.tls_force_run
TLS debugging - https://www.kamailio.org/wiki/tutorials/tls/testing-and-debugging
