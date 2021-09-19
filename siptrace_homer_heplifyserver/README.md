# Monitoring and auditing SIP traffic 

Homer and homer encapsulation protocl (HEP) integration with sip server brings the capabilities to 
SIP/SDP payload retention with precise timestamping
better monitor and detect anomilies in call tarffic and events
correlation of session ,logs , reports 
also the power to bring charts and statictics for SIP and RTP/RTCP packets etc

We read about sipcapture and sip trace modules in project sipcapture_siptrace_hep.

In this project, focus will be on configuring heplify server which actas as sip capture agant for tarffic coming from kamailio sip trace agents.

## HOMER 

Packet and Event capture system  
VoiP/RTC Monitoring Application 
based on HEP/EEP (Extensible Encapsulation protocol)

## heplify 

install go ( above version 1.11)
```
wget https://dl.google.com/go/go1.11.2.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.11.2.linux-amd64.tar.gz
```
move package to /usr/local/go
```
mv go 
```

Either add go bin to ~/.profile
```
export PATH=$PATH:/usr/local/go/bin
```
and apply
```
source ~/.profile
```
or set GO ROOT , and GOPATH
```
export GOROOT=/usr/local/go
export GOPATH=$HOME/heplify
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
```
installation of dependencies
```
go get
```
clone heplify repo and make 
```
make 
```

## HEPop
stand-alone HEP Capture Server designed for HOMER7 capable of emitting indexed datasets and tagged timeseries to multiple backends


## influx DB

time series Reltiem DB 
install
```
wget https://dl.influxdata.com/influxdb/releases/influxdb_1.7.7_amd64.deb
sudo dpkg -i influxdb_1.7.7_amd64.deb
```
start
```
 >influxd
 8888888           .d888 888                   8888888b.  888888b.
   888            d88P"  888                   888  "Y88b 888  "88b
   888            888    888                   888    888 888  .88P
   888   88888b.  888888 888 888  888 888  888 888    888 8888888K.
   888   888 "88b 888    888 888  888  Y8bd8P' 888    888 888  "Y88b
   888   888  888 888    888 888  888   X88K   888    888 888    888
   888   888  888 888    888 Y88b 888 .d8""8b. 888  .d88P 888   d88P
 8888888 888  888 888    888  "Y88888 888  888 8888888P"  8888888P"

2019-07-19T07:03:04.603494Z	info	InfluxDB starting	{"log_id": "0GjGVvbW000", "version": "1.7.7", "branch": "1.7", "commit": "f8fdf652f348fc9980997fe1c972e2b79ddd13b0"}
2019-07-19T07:03:04.603756Z	info	Go runtime	{"log_id": "0GjGVvbW000", "version": "go1.11", "maxprocs": 1}
2019-07-19T07:03:04.707567Z	info	Using data dir	{"log_id": "0GjGVvbW000", "service": "store", "path": "/var/lib/influxdb/data"}
```
## siptrace module
SIPtrace module offer a possibility to store incoming and outgoing SIP messages in a database and/or duplicate to the capturing server (using HEP, the Homer encapsulation protocol, or plain SIP mode).
```
loadmodule "siptrace.so"
modparam("siptrace", "duplicate_uri", "sip:127.0.0.1:9060")
modparam("siptrace", "hep_mode_on", 1)
modparam("siptrace", "trace_to_database", 0)
modparam("siptrace", "trace_flag", 22)
modparam("siptrace", "trace_on", 1)
```
integrating iut with request route to start duplicating the sip messages
```
sip_trace();
setflag(22);
```
* trace_mode *
1 -  uses core events triggered when receiving or sending SIP traffic to mirror traffic to a SIP capture server using HEP
0 -  no automatic mirroring of SIP traffic via HEP.
## duplicate 
address in form of a SIP URI where to send a duplicate of traced message. It uses UDP all the time.
```
modparam("siptrace", "duplicate_uri", "sip:127.0.0.1:9060")
```
to check the duplicate messages arriving
```
ngrep -W byline -d any port 9060 -q
```
### RPC commands
Can ruen sip trace on or off 
```
kamcmd> siptrace.status on   
Enabled
```
and to check
```
kamcmd> siptrace.status check
Enabled
```
## Store sip_trace in database 
```
modparam("siptrace", "trace_to_database", 1)
modparam("siptrace", "db_url", DBURL)
modparam("siptrace", "table", "sip_trace")
```
where the sip_trace tabel description is 
```
+-------------+------------------+------+-----+---------------------+----------------+
| Field       | Type             | Null | Key | Default             | Extra          |
+-------------+------------------+------+-----+---------------------+----------------+
| id          | int(10) unsigned | NO   | PRI | NULL                | auto_increment |
| time_stamp  | datetime         | NO   | MUL | 2000-01-01 00:00:01 |                |
| time_us     | int(10) unsigned | NO   |     | 0                   |                |
| callid      | varchar(255)     | NO   | MUL |                     |                |
| traced_user | varchar(128)     | NO   | MUL |                     |                |
| msg         | mediumtext       | NO   |     | NULL                |                |
| method      | varchar(50)      | NO   |     |                     |                |
| status      | varchar(128)     | NO   |     |                     |                |
| fromip      | varchar(50)      | NO   | MUL |                     |                |
| toip        | varchar(50)      | NO   |     |                     |                |
| fromtag     | varchar(64)      | NO   |     |                     |                |
| totag       | varchar(64)      | NO   |     |                     |                |
| direction   | varchar(4)       | NO   |     |                     |                |
+-------------+------------------+------+-----+---------------------+----------------+
```
sample databse storage for sip traces 
```
select * from sip_trace;

| id | time_stamp          | time_us | callid  | traced_user | msg         | method | status | fromip                   | toip                     | fromtag  | totag    | direction |
+----+---------------------+---------+---------------------------------------------+-------------+-----------------------------------
|  1 | 2019-07-18 09:00:18 |  417484 | MTlhY2VmNDdjN2QxZGM5ZDFhMWRhZThhZDU4YjE0MGM |             | INVITE sip:altanai@sip_addr;transport=udp SIP/2.0
Via: SIP/2.0/UDP local_addr:25584;branch=z9hG4bK-d8754z-1f5a337092a84122-1---d8754z-;rport
Max-Forwards: 70
Contact: <sip:derek@call_addr:7086;transport=udp>
To: <sip:altanai@sip_addr>
From: <sip:derek@sip_addr>;tag=de523549
Call-ID: MTlhY2VmNDdjN2QxZGM5ZDFhMWRhZThhZDU4YjE0MGM
CSeq: 1 INVITE
Allow: INVITE, ACK, CANCEL, OPTIONS, BYE, REFER, NOTIFY, MESSAGE, SUBSCRIBE, INFO
Content-Type: application/sdp
Supported: replaces
User-Agent: Bria 3 release 3.5.5 stamp 71243
Content-Length: 214

v=0
o=- 1563440415743829 1 IN IP4 local_addr
s=Bria 3 release 3.5.5 stamp 71243
c=IN IP4 local_addr
t=0 0
m=audio 59814 RTP/AVP 9 8 0 101
a=rtpmap:101 telephone-event/8000
a=fmtp:101 0-15
a=sendrecv                                                                                                                                                                                      | INVITE |        | udp:caller_addr:27982 | udp:sip_pvt_addr:5060   | de523549 |          | in        |

|  2 | 2019-07-18 09:00:18 |  421675 | MTlhY2VmNDdjN2QxZGM5ZDFhMWRhZThhZDU4YjE0MGM |             | SIP/2.0 100 trying -- your call is important to us
Via: SIP/2.0/UDP local_addr:25584;branch=z9hG4bK-d8754z-1f5a337092a84122-1---d8754z-;rport=27982;received=caller_addr
To: <sip:altanai@sip_addr>
From: <sip:derek@sip_addr>;tag=de523549
Call-ID: MTlhY2VmNDdjN2QxZGM5ZDFhMWRhZThhZDU4YjE0MGM
CSeq: 1 INVITE
Server: kamailio (5.2.3 (x86_64/linux))
Content-Length: 0                                                                                                                                                                                                                                                                                                                                                                                                                                                           | ACK    |        | udp:caller_addr:27982 | udp:local_addr:5060   | de523549 | b2d8ad3f | in       |
...
+----+---------------------+---------+---------------------------------------------+-------------+-----------------------------------
```

## Debug : 

Issue : go build github.com/sipcapture/heplify/config: module requires Go 1.12
solution : upgrade to 1.12 
manage node version easily using gvm / go versioing manager 
```
curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
gvm install go1.12
gvm use go1.12
```



Ref : 
sip trace module - http://www.kamailio.org/docs/modules/5.2.x/modules/siptrace.html
