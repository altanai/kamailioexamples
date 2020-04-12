# Stateful Kamailio Server with Lua prigramming and RTP engine integration 

Kamailio is basically only a transaction stateful proxy, without any dialog support build in.
To make it stateful , we add dialog support that provides awareness, 
like storing the information in the dialog creation stage, that can be used during the whole dialog existence.

**Route headers**
Record additional dialog-related information in the routing set (Record-Route/Route headers) headers 
They show up in all sequential requests.
Applications are found in NAT traversal

## Install 

```
make include_modules="app_lua xmlrpc json" cfg
sudo make all
sudo make install
```

**conventions**

-- KSR - the new dynamic object exporting Kamailio functions (kemi)
-- sr - the old static object exporting Kamailio functions

## Run
```
kamailio -f kamailio_lua.cfg -Ee
```

## RTPengine from dbtext
```
1:1:udp\:<ip>\:<port>:1:0:0
```

## UAC
simulate a UAC to send calls to Kamailio SIP server and RTP engine proxy
```bash
sipp -sn uac -d 80000 -s altanai <sipserverip:port> -i <uacip>  -m 1 -rp 1 -max_retrans 1
```

## Dispatcher in kamailio

Add the destination details in dispatcher list on kamailip SIP sever
```bash
1 sip:<uasip:port> 0 0 0
```

## UAS
Simulate a UAS to receive calls from kamailio SIP server and RTP Engine rpoxy
```bash
sipp -sn uas -i <uasip> -p <uasport> -trace_err -aa
```
-aa to automate handling of SIP INFO, OPTIONS, NOTIFY etc with 200 ok

## Debugging 

**Issue1** RTP engine not acessible or found
 4(95144) INFO: <core> [core/kemi.c:150]: sr_kemi_core_log(): response contains sdp, answer to rtpengine 
 4(95144) ERROR: rtpengine [rtpengine.c:2928]: select_rtpp_set(): no rtpp_set_list->rset_first
 4(95144) ERROR: rtpengine [rtpengine.c:3138]: select_rtpp_node(): script error - no valid set selected
 4(95144) ERROR: rtpengine [rtpengine.c:2562]: rtpp_function_call(): no available proxies
 4(95144) ERROR: <core> [core/kemi.c:156]: sr_kemi_core_log(): received failure reply for rtpengine answer from instance 
**Solution** Either find a publically or self accessible rtpengine or download source and build your own manaully 
```bash
git clone git@github.com:sipwise/rtpengine.git
 cd rtpengine
```
dependencies like openssl
```bash
export PKG_CONFIG_PATH="/usr/local/opt/openssl@1.1/lib/pkgconfig"
brew link openssl
```
or if openssl isnt found then 
```bash
brew reinstall openssl@1.1
```

hiredis
```bash
brew install hiredis
```

spandsp
```bash
brew install spandsp
```

libiptc library for iptables management
```bash
brew install libiptcdata
```
for sys/epoll.h
```bash
brew install libuv
```

tbd working on epoll on mac osx
```bash
fatal error: 'sys/epoll.h' file not found
```
**Ref** :

KEMI - https://kamailio.org/docs/tutorials/devel/kamailio-kemi-framework
RTPEngine module - https://kamailio.org/docs/modules/devel/modules/rtpengine.htm
Dispatcher module - https://www.kamailio.org/docs/modules/5.1.x/modules/dispatcher.html#dispatcher.f.ds_select_domain