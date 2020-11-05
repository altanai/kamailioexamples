## Kamailio cfgs

kamailio configurations and associated files for various usecases and role that kamailio can fit into

### Usecases 
* Barebonde SIP Server - use bare minimum modules and replies to any incoming call , no relay or proxy , no nat etc
* REGISTER handle - just replies 300 ok to every REGISTER type request method
* Stateful transaction handle 
* Simple Relay - relays incoming SIP messages to another end
* Record routing
* NAT handle 
* REGISTER and Userloc
* RTPENgine media proxy
* Accounting 
* WebRTC WS SIP Server


Note : Used kamailio v5.x , many old examples and sample configs from older wiki sources have been updated here too

## TLS protocol method

Possible values are:
- TLSv1.2 - only TLSv1.2 connections are accepted (available starting with openssl/libssl v1.0.1e)
- TLSv1.1+ - TLSv1.1 or newer (TLSv1.2, ...) connections are accepted (available starting with openssl/libssl v1.0.1)
- TLSv1.1 - only TLSv1.1 connections are accepted (available starting with openssl/libssl v1.0.1)
- TLSv1+ - TLSv1.0 or newer (TLSv1.1, TLSv1.2, ...) connections are accepted.
- TLSv1 - only TLSv1 (TLSv1.0) connections are accepted. This is the default value.
- SSLv3 - only SSLv3 connections are accepted. Note: you shouldn't use SSLv3 for anything which should be secure.
- SSLv2 - only SSLv2 connections, for old clients. Note: you shouldn't use SSLv2 for anything which should be secure. Newer versions of libssl don't include support for it anymore.
- SSLv23 - any of the SSLv2, SSLv3 and TLSv1 or newer methods will be accepted.


Ref :
https://downloads2.goautodial.org/files/version4/etc/kamailio/kamailio-wss+sip.cfg
