
## Kamailio  RTPengine 

Sipwise NGCP rtpengine is a proxy for RTP traffic and other UDP based media traffic.

step 1 : Setup registrar

UA1 john --- REGISTER --> kamailio registrar 
UA2 alice --- REGISTER --> kamailio registrar

step 2 : haddle invite 

UA1 --INVITE --> Kamailio proxy 

Kamailio proxy -- offer --> RTP Engine 

final step : Call is established 

UA1 -- sip -->kamailio --> UA2
UA1 -- rtp --> RTP engine --> UA2



## Quick RTPengine  Installation using 

For detailed steps goto https://telecom.altanai.com/2018/04/03/rtp-engine-on-kamailio-sip-server/

dependencies
```
apt-get remove rtpproxy
sudo apt install debhelper iptables-dev libcurl4-openssl-dev libglib2.0-dev libxmlrpc-core-c3-dev libhiredis-dev markdown build-essential:native
```
source 
```
git clone https://github.com/sipwise/rtpengine.git
cd rtpengine
 ./debian/flavors/no_ngcp
```
build package and install deb files
```
sudo dpkg-buildpackage
sudo dpkg -i ngcp-rtpengine-daemon_4.1.0.0+0~mr4.1.0.0_amd64.deb
sudo dpkg -i ngcp-rtpengine-iptables_4.1.0.0+0~mr4.1.0.0_amd64.deb
sudo dpkg -i ngcp-rtpengine-dbg_4.1.0.0+0~mr4.1.0.0_amd64.deb
sudo apt-get -f install
sudo dpkg -i ngcp-rtpengine-kernel-dkms_4.1.0.0+0~mr4.1.0.0_all.deb
sudo dpkg -i ngcp-rtpengine-kernel-source_4.1.0.0+0~mr4.1.0.0_all.deb
sudo dpkg -i ngcp-rtpengine_4.1.0.0+0~mr4.1.0.0_all.deb
```
edit the /etc/default/ngcp-rtpengine-daemon file.
```
RUN_RTPENGINE=yes
LISTEN_UDP=12222
LISTEN_NG=22222
LISTEN_CLI=9900
INTERFACES="internal/10.140.3.246!52.20.136.229 external/52.20.136.229"
TIMEOUT=60
SILENT_TIMEOUT=3600
PIDFILE=/var/run/ngcp-rtpengine-daemon.pid
FORK=yes
TABLE=0
PORT_MIN=40000
PORT_MAX=60000
```

## Run 

rtpengine --interface=54.86.35.95 --listen-ng=25061 --listen-cli=25062 --foreground --log-stderr --listen-udp=2222 --listen-tcp=25060

or 

starting ngcp-rtp daemon service
```sh
/etc/init.d/ngcp-rtpengine-daemon start
[ ok ] Starting ngcp-rtpengine-daemon (via systemctl): ngcp-rtpengine-daemon.service.
```

log checks form syslog
```sh
tail -f /var/log/syslog
rtpengine[12058]: DEBUG: timer run time = 0.000032 sec
rtpengine[12058]: DEBUG: timer run time = 0.000034 sec
...
```
 checks threads 
 ```
>ps -ef | grep ngcp-rtpengine
 ```


## Integartion with kamailio 

```
loadmodule "rtpengine.so"
modparam("rtpengine", "rtpengine_sock", "udp:127.0.0.1:22222")

...

if (is_method("INVITE|REFER")) {
    record_route();
    if (has_body("application/sdp")) {
        if (rtpengine_offer()) {
            t_on_reply("1");
        }
    } else {
        t_on_reply("2");
    }

    ...
    
    if (is_method("ACK") && has_body("application/sdp")) {
            rtpengine_answer();
    }

    route(RELAY);
}

...


```


## Working 

Offer 

```
s=Bria 3 release 3.5.5 stamp 71243
c=IN IP4 rtp_engine_ip
t=0 0
m=audio 51472 RTP/AVP 9 0 18 98 101
a=rtpmap:18 G729/8000
a=fmtp:18 annexb=yes
a=rtpmap:98 ILBC/8000
a=rtpmap:101 telephone-event/8000
a=fmtp:101 0-15
a=sendrecv
", "call-id": "callid", "received-from": [ "IP4", "sip_ua_ip" ], "from-tag": "5198f57f", "command": "offer" }
[[ID="callid"]: Creating new call
[ID="callid"]: Default sink codec is G722/8000
[ID="callid"]: Creating codec handler for G722/8000
[ID="callid"]: Sink supports codec G722/8000
[ID="callid"]: Creating codec handler for PCMU/8000
[ID="callid"]: Sink supports codec PCMU/8000
[ID="callid"]: Creating codec handler for G729/8000
[ID="callid"]: Creating codec handler for ILBC/8000
[ID="callid"]: Creating codec handler for telephone-event/8000
[ID="callid"]: creating send_timer
[ID="callid"]: creating send_timer
[ID="callid"]: creating send_timer
[ID="callid"]: creating send_timer
[ID="callid"]: set FILLED flag for stream rtp_engine_ip:51472
[ID="callid"]: set FILLED flag for stream rtp_engine_ip:51473[ID="callid"]: Replying to 'offer' from from_ip:57166 (elapsed time 0.001471 sec)
[1563192870.453903] DEBUG: [ID="callid"]: Response dump for 'offer' to from_ip:57166: { "sdp": "v=0
o=- 1563192870324300 1 IN IP4 rtp_engine_ip
s=Bria 3 release 3.5.5 stamp 71243
c=IN IP4 rtp_engine_pub_ip
t=0 0
m=audio 10052 RTP/AVP 9 0 18 98 101
a=rtpmap:9 G722/8000
a=rtpmap:0 PCMU/8000
a=rtpmap:18 G729/8000
a=rtpmap:98 ILBC/8000
a=rtpmap:101 telephone-event/8000
a=fmtp:18 annexb=yes
a=fmtp:101 0-15
a=sendrecv
a=rtcp:10053
a=ice-ufrag:J2eKBWSO
a=ice-pwd:3MjkMLYAKe3CN4rvCtQEq1twAK
a=candidate:b2yZ1hLMPAbVI08J 1 UDP 2130706431 rtp_engine_pub_ip 10052 typ host
a=candidate:b2yZ1hLMPAbVI08J 2 UDP 2130706430 rtp_engine_pub_ip 10053 typ host
", "result": "ok" }
[1563192872.000170] DEBUG:
```


Ref : 
sipwise RTP engine https://github.com/sipwise/rtpengine