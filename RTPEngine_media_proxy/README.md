
## sipwise RTPengine 

Sipwise NGCP rtpengine is a proxy for RTP traffic and other UDP based media traffic.
esentially it is a Kernel-based packet controlled by sip proxy server usually on UDP port 22222
it maintains a pair of ports on public interface for each media stream audio or video
one pair on odd port numbers for the media data ( RTP) , and one pair on the next even port numbers for meta data (RTCP)

When the media streams are negotiated, rtpengine opens the ports in user-space and starts relaying the packets to the addresses announced by the endpoints.

When NAT is applied , sip packets may come from a diff source address than declared in SDP, in such a case source address is implicitly changed to the address the packets are received from.

Once the call is established and the rtpengine has received media packets from both endpoints for this call, the media stream is pushed into the kernel and is then handled by a custom Sipwise iptables module to increase the throughput of the system and to reduce the latency of media packets. 

## steps 
* step 1 : Setup registrar

UA1 john --- REGISTER --> kamailio registrar 
UA2 alice --- REGISTER --> kamailio registrar

* step 2 : handle invite 

UA1 --INVITE --> Kamailio proxy 

when SDP arrives in INVITE message , make an offer to rtpengine 
Kamailio proxy -- offer --> RTP Engine 

* final step : Call is established 

UA1 -- sip -->kamailio --> UA2
UA1 -- rtp --> RTP engine --> UA2

As sip messages proxy via the SIP server , the rtp packets relay via the rtpengine

## Quick RTPengine Installation using 

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
edit the /etc/default/ngcp-rtpengine-daemon file with interfaces 
```
RUN_RTPENGINE=yes
LISTEN_UDP=12222
LISTEN_NG=22222
LISTEN_CLI=9900
INTERFACES="internal/10.20.30.40!123.234.345.567 external/123.234.345.567"
TIMEOUT=60
SILENT_TIMEOUT=3600
PIDFILE=/var/run/ngcp-rtpengine-daemon.pid
FORK=yes
TABLE=0
PORT_MIN=40000
PORT_MAX=60000
```

## Run 

Can run in foreground mode
```
rtpengine --interface=x.x.x.x --listen-ng=25061 --listen-cli=25062 --foreground --log-stderr --listen-udp=22222 --listen-tcp=25060
```
or as daemon service 

starting ngcp-rtp daemon service
```sh
/etc/init.d/ngcp-rtpengine-daemon start
[ ok ] Starting ngcp-rtpengine-daemon (via systemctl): ngcp-rtpengine-daemon.service.
```
check status 
```
>systemctl status ngcp-rtpengine-daemon.service
● ngcp-rtpengine-daemon.service - NGCP RTP/media Proxy Daemon
   Loaded: loaded (/lib/systemd/system/ngcp-rtpengine-daemon.service; disabled; vendor preset: enabled)
   Active: active (running) since Fri 2018-07-26 14:53:20 UTC; 5s ago
  Process: 24594 ExecStopPost=/usr/sbin/ngcp-rtpengine-iptables-setup stop (code=exited, status=0/SUCCESS)
  Process: 24640 ExecStartPre=/usr/sbin/ngcp-rtpengine-iptables-setup start (code=exited, status=0/SUCCESS)
 Main PID: 24657 (rtpengine)
    Tasks: 20
   Memory: 12.5M
      CPU: 71ms
   CGroup: /system.slice/ngcp-rtpengine-daemon.service
           └─24657 /usr/sbin/rtpengine -f -E --no-log-timestamps --pidfile /run/ngcp-rtpengine-daemon.pid --config-file /etc/rtpengine/rtpengine.conf --table 0

systemd[1]: Starting NGCP RTP/media Proxy Daemon...
rtpengine[24657]: INFO: Generating new DTLS certificate
rtpengine[24657]: INFO: Startup complete, version 7.5.0.0+0~mr7.5.0.0 git-master-3b6f098
systemd[1]: Started NGCP RTP/media Proxy Daemon.
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
```

kamcmd reload rtpengine
```
kamcmd -s tcp:x.x.x.x:2046 rtpengine.reload
```
kamcmd check rtpengine status
```
kamcmd -s tcp:x.x.x.x:2046 rtpengine.show all
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

## RTP engine options 

  -v, --version                                               Print build time and exit
  --config-file=FILE                                          Load config from this file
  --config-section=STRING                                     Config file section to use
  --log-facility=daemon|local0|...|local7                     Syslog facility to use for logging
  -L, --log-level=INT                                         Mask log priorities above this level
  -E, --log-stderr                                            Log on stderr instead of syslog
  --no-log-timestamps                                         Drop timestamps from log lines to stderr
  --log-mark-prefix                                           Prefix for sensitive log info
  --log-mark-suffix                                           Suffix for sensitive log info
  -p, --pidfile=FILE                                          Write PID to file
  -f, --foreground                                            Don't fork to background
  -t, --table=INT                                             Kernel table to use
  -F, --no-fallback                                           Only start when kernel module is available
  -i, --interface=[NAME/]IP[!IP]                              Local interface for RTP
  -k, --subscribe-keyspace=INT INT ...                        Subscription keyspace list
  -l, --listen-tcp=[IP:]PORT                                  TCP port to listen on
  -u, --listen-udp=[IP46|HOSTNAME:]PORT                       UDP port to listen on
  -n, --listen-ng=[IP46|HOSTNAME:]PORT                        UDP port to listen on, NG protocol
  -c, --listen-cli=[IP46|HOSTNAME:]PORT                       UDP port to listen on, CLI
  -g, --graphite=IP46|HOSTNAME:PORT                           Address of the graphite server
  -G, --graphite-interval=INT                                 Graphite send interval in seconds
  --graphite-prefix=STRING                                    Prefix for graphite line
  -T, --tos=INT                                               Default TOS value to set on streams
  --control-tos=INT                                           Default TOS value to set on control-ng
  -o, --timeout=SECS                                          RTP timeout
  -s, --silent-timeout=SECS                                   RTP timeout for muted
  -a, --final-timeout=SECS                                    Call timeout
  --offer-timeout=SECS                                        Timeout for incomplete one-sided calls
  -m, --port-min=INT                                          Lowest port to use for RTP
  -M, --port-max=INT                                          Highest port to use for RTP
  -r, --redis=[PW@]IP:PORT/INT                                Connect to Redis database
  -w, --redis-write=[PW@]IP:PORT/INT                          Connect to Redis write database
  --redis-num-threads=INT                                     Number of Redis restore threads
  --redis-expires=INT                                         Expire time in seconds for redis keys
  -q, --no-redis-required                                     Start no matter of redis connection state
  --redis-allowed-errors=INT                                  Number of allowed errors before redis is temporarily disabled
  --redis-disable-time=INT                                    Number of seconds redis communication is disabled because of errors
  --redis-cmd-timeout=INT                                     Sets a timeout in milliseconds for redis commands
  --redis-connect-timeout=INT                                 Sets a timeout in milliseconds for redis connections
  -b, --b2b-url=STRING                                        XMLRPC URL of B2B UA
  --log-facility-cdr=daemon|local0|...|local7                 Syslog facility to use for logging CDRs
  --log-facility-rtcp=daemon|local0|...|local7                Syslog facility to use for logging RTCP
  --log-facility-dtmf=daemon|local0|...|local7                Syslog facility to use for logging DTMF
  --log-format=default|parsable                               Log prefix format
  -x, --xmlrpc-format=INT                                     XMLRPC timeout request format to use. 0: SEMS DI, 1: call-id only, 2: Kamailio
  --num-threads=INT                                           Number of worker threads to create
  --media-num-threads=INT                                     Number of worker threads for media playback
  -d, --delete-delay=INT                                      Delay for deleting a session from memory.
  --sip-source                                                Use SIP source address by default
  --dtls-passive                                              Always prefer DTLS passive role
  --max-sessions=INT                                          Limit of maximum number of sessions
  --max-load=FLOAT                                            Reject new sessions if load averages exceeds this value
  --max-cpu=FLOAT                                             Reject new sessions if CPU usage (in percent) exceeds this value
  --max-bandwidth=INT                                         Reject new sessions if bandwidth usage (in bytes per second) exceeds this value
  --homer=IP46|HOSTNAME:PORT                                  Address of Homer server for RTCP stats
  --homer-protocol=udp|tcp                                    Transport protocol for Homer (default udp)
  --homer-id=INT                                              'Capture ID' to use within the HEP protocol
  --recording-dir=FILE                                        Directory for storing pcap and metadata files
  --recording-method=pcap|proc                                Strategy for call recording
  --recording-format=raw|eth                                  File format for stored pcap files
  --iptables-chain=STRING                                     Add explicit firewall rules to this iptables chain
  --codecs                                                    Print a list of supported codecs and exit
  --scheduling=default|none|fifo|rr|other|batch|idle          Thread scheduling policy
  --priority=INT                                              Thread scheduling priority
  --idle-scheduling=default|none|fifo|rr|other|batch|idle     Idle thread scheduling policy
  --idle-priority=INT                                         Idle thread scheduling priority
  --log-srtp-keys                                             Log SRTP keys to error log
  --mysql-host=HOST|IP                                        MySQL host for stored media files
  --mysql-port=INT                                            MySQL port
  --mysql-user=USERNAME                                       MySQL connection credentials
  --mysql-pass=PASSWORD                                       MySQL connection credentials
  --mysql-query=STRING                                        MySQL select query

## Debugging 

**Issue1** : unknowdn codecs 
```
[1564587040.078220] INFO: [ogi3dpopec8u56dffe3s]: --- Tag 'ufhj8jv9hg', created 0:00 ago for branch '', in dialogue with ''
[1564587040.078228] INFO: [ogi3dpopec8u56dffe3s]: ------ Media #1 (audio over UDP/TLS/RTP/SAVPF) using unknown codec
[1564587040.078298] INFO: [ogi3dpopec8u56dffe3s]: --- Tag '', created 0:00 ago for branch '', in dialogue with 'ufhj8jv9hg'
[1564587040.078306] INFO: [ogi3dpopec8u56dffe3s]: ------ Media #1 (audio over UDP/TLS/RTP/SAVPF) using unknown codec
```
**solution** : verify the list of codecs supported 
```
> rtpengine --codecs
                PCMA: fully supported
                PCMU: fully supported
                G723: fully supported
                G722: fully supported
               QCELP: supported for decoding only
                G729: supported for decoding only
               speex: fully supported
                 GSM: fully supported
                iLBC: not supported
                opus: fully supported
              vorbis: codec supported but lacks RTP definition
                 ac3: codec supported but lacks RTP definition
                eac3: codec supported but lacks RTP definition
              ATRAC3: supported for decoding only
             ATRAC-X: supported for decoding only
                 AMR: supported for decoding only
              AMR-WB: supported for decoding only
     telephone-event: fully supported
           PCM-S16LE: codec supported but lacks RTP definition
              PCM-U8: codec supported but lacks RTP definition
                 MP3: codec supported but lacks RTP definition
```
Assume the coedec list is 
```
m=audio 55215 UDP/TLS/RTP/SAVPF 111 103 104 9 0 8 106 105 13 110 112 113 126
...
a=sendrecv
a=msid:LFYfHwNOw5Bz1FMVswSH66PueKArRgdmPUtI 1f578b40-b2ee-46da-b731-d35a76a75e9d
a=rtcp-mux
a=rtpmap:111 opus/48000/2
a=rtcp-fb:111 transport-cc
a=fmtp:111 minptime=10;useinbandfec=1
a=rtpmap:103 ISAC/16000
a=rtpmap:104 ISAC/32000
a=rtpmap:9 G722/8000
a=rtpmap:0 PCMU/8000
a=rtpmap:8 PCMA/8000
a=rtpmap:106 CN/32000
a=rtpmap:105 CN/16000
a=rtpmap:13 CN/8000
a=rtpmap:110 telephone-event/48000
a=rtpmap:112 telephone-event/32000
a=rtpmap:113 telephone-event/16000
a=rtpmap:126 telephone-event/8000
```

Ref : 
sipwise RTP engine https://github.com/sipwise/rtpengine