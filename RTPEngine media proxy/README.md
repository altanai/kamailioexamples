
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



## Quick RTPengine  Installation

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
Jul  4 07:09:33 ip-172-31-90-251 rtpengine[12058]: DEBUG: timer run time = 0.000032 sec
Jul  4 07:09:34 ip-172-31-90-251 rtpengine[12058]: DEBUG: timer run time = 0.000034 sec
...
```
 checks threads 
 ```
>ps -ef | grep ngcp-rtpengine
 ```


## Integartion with kamailio 

```
modparam("rtpengine", "rtpengine_sock", "udp:127.0.0.1:22222")
```


## Working 





Ref : 
sipwise RTP engine https://github.com/sipwise/rtpengine