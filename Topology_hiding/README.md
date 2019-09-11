# Topology hiding for securing VoIP system 

hides the SIP routing headers that show topology details.

script interpreter gets the SIP messages decoded, so all existing functionality is preserved.

The module is transparent for the configuration writer. It only needs to be loaded (tune the parameters if needed). The SIP server can be restarted without affecting ongoing calls - once it is up, can encode/decode topology details, thus no call will be lost.

By using same mask_key, many SIP servers can decode the message, for example, applicable for servers behind load balancers.

## Configuration 
Dependencies to build topos  / topoh module 
```
apt-get install libhiredis-dev
apt-get install uuid-dev
```

Ref :
topoh https://kamailio.org/docs/modules/devel/modules/topoh.html