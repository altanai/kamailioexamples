# WebRTC to WebRTC call on TLS , media relay via RTP engine 

This is the next step from webrtc_to_webrtc_ws section.
Note it doesnt not support sip client or ports on 5060 . Only works for websocket and wss port

## installing RTpengine
```
echo 'deb http://deb.sipwise.com/spce/mr7.1.1/ stretch main' > /etc/apt/sources.list.d/sipwise.list
echo 'deb-src http://deb.sipwise.com/spce/mr7.1.1/ stretch main' >> /etc/apt/sources.list.d/sipwise.list
apt-get update
apt-get install -y --allow-unauthenticated ngcp-keyring
apt-get update
apt-get install -y ngcp-rtpengine
```
RTPengine configuration file 
```
[rtpengine]
RUN_RTPENGINE=yes
listen-ng = 22222
listen-tcp = 25060
listen-udp = 12222
LISTEN-CLI=9900
interface = internal/private_ip!public_ip;external/public_ip
TIMEOUT=60
SILENT_TIMEOUT=3600
PIDFILE=/var/run/ngcp-rtpengine-daemon.pid
FORK=yes
TABLE=0
PORT_MIN=40000
PORT_MAX=60000
```

## Debug help

**Issues 1** : CRIT: Fatal error: Bad command line: Key file does not start with a group
**solution** : add a group like [rtpengine] to the header of the file 

**Issues 2** : CRIT: Fatal error: Missing option --interface
**solution** : Add interface from formats, such as 
a single interface:
```
interface = 123.234.345.456
```
separate multiple interfaces with semicolons:
```
interface = internal/10.20.30.40;external/123.234.345.456
```
for different advertised address:
```
interface = 12.23.34.45!23.34.45.56
```
**Issue 3**: CRIT: Fatal error: Missing option --listen-tcp, --listen-udp or --listen-ng
**Solution** : Add listen option 