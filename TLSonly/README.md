# Secure TLS connection via port 5061 

Securinng signalling using TLS certificates to provide privacy to voip calls over public internet.
I have used self signed certificate in this exmaple which is ok for dev enviornment for staging , beta or production env use third party certificate provider ( Letsencrypt etc , I will add more on that later )

## Steps for TLS module in kamailio

Build tls module in kamailio src 
```
make -C modules/tls extra_defs="-DTLS_WR_DEBUG -DTLS_RD_DEBUG"
```

Add it to cfg load module 
```
loadmodule "sl.so"
loadmodule "tls.so"
```
provide either tls params of path to tls.cfg holding tls params like private_key , certificate , tls methods etc
```
modparam("tls", "private_key", "/etc/kamailio/certs/provkey.pem")
modparam("tls", "certificate", "/etc/kamailio/certs/cert.pem")
modparam("tls", "ca_list", "/etc/kamailio/certs/calist.pem")
```
or
```
[server:default]
method = TLSv1
verify_certificate = no
require_certificate = no
private_key = /etc/kamailio/certs/provkey.pem
certificate = /etc/kamailio/certs/cert.pem"
```
Add listen address , also add advertise publicip:secire sip port for one behind NAT
```
listen=tls:MY_IP_ADDR:MY_SIPS_PORT advertise MY_EXTERNAL_IP:MY_SIPS_PORT
```

Enable TLS module. Optionally u can check for proto or can use pseudo variable $pr
```
enable_tls=yes

request_route {
	if(proto != TLS) {
		sl_send_reply("403", "Accepting TLS Only");
		exit;
	}
	...
}
```

## Traces 
snippet of traces from TLS connection
```
tcpconn_new: new tcp connection: ua_addr
tcpconn_new(): on port 23235, type 3
tcpconn_add(): hashes: 3659:631:405, 2
DEBUG: <core> [core/io_wait.h:380]: io_watch_add(): DBG: io_watch_add(0xa87960, 46, 2, 0x7fb7cc2f0190), fd_no=39
DEBUG: <core> [core/io_wait.h:602]: io_watch_del(): DBG: io_watch_del (0xa87960, 46, -1, 0x0) fd_no=40 called
DEBUG: <core> [core/tcp_main.c:4196]: handle_tcpconn_ev(): sending to child, events 1
DEBUG: <core> [core/tcp_main.c:3875]: send2child(): selected tcp worker idx:0 proc:22 pid:2973 for activity on [tcp:ip_addr:5061], 0x7fb7cc2f0190
DEBUG: <core> [core/tcp_read.c:1759]: handle_io(): received n=8 con=0x7fb7cc2f0190, fd=5
DEBUG: <core> [core/io_wait.h:380]: io_watch_add(): DBG: io_watch_add(0xae1280, 5, 2, 0x7fb7cc2f0190), fd_no=1
DEBUG: <core> [core/io_wait.h:602]: io_watch_del(): DBG: io_watch_del (0xae1280, 5, -1, 0x10) fd_no=2 called
DEBUG: <core> [core/tcp_read.c:1680]: release_tcpconn(): releasing con 0x7fb7cc2f0190, state 1, fd=5, id=1 ([ua_addr]:47439 -> [ua_addr]:5061)
DEBUG: <core> [core/tcp_read.c:1684]: release_tcpconn(): extra_data (nil)
DEBUG: <core> [core/tcp_main.c:3307]: handle_tcp_child(): reader response= 7fb7cc2f0190, 1 from 0 
DEBUG: <core> [core/io_wait.h:380]: io_watch_add(): DBG: io_watch_add(0xa87960, 46, 2, 0x7fb7cc2f0190), fd_no=39
DEBUG: <core> [core/tcp_main.c:3434]: handle_tcp_child(): CONN_RELEASE  0x7fb7cc2f0190 refcnt= 1
```

## using sipp + TLS as UAC

Compile sipp from source 
```bash
git clone git@github.com:SIPp/sipp.git
```

using the default make instructions
```bash
cmake . 
make
```
But for tls enabling use below : 

Pre-requisites to compile SIPp are :
    C++ Compiler
    curses or ncurses library
    For TLS support: OpenSSL >= 0.9.8
    For pcap play support: libpcap and libnet
    For SCTP support: lksctp-tools
    For distributed pauses: Gnu Scientific Libraries

For example on ubuntu system 
For compiling 
```
sudo apt-get install cmake build-essential
```
For the optional flag
```
sudo apt-get install dh-autoreconf
sudo apt-get install ncurses-dev libncurses5-dev
```
LibSSL like bio.h
```
sudo apt-get install libssl-dev
```
SCTP
```
sudo apt-get install libsctp-dev lksctp-tools
```
PCAP like pcap.h
```
sudo apt-get install libpcap-dev
```

I could not compile it on my mac system due to bio.h headr missing in openssl , I read about it for a while and looks like a lile s link issues .

use  optional flags to enable features (SIP-over-TLS
```bash
cmake . -DUSE_SSL=1
make
```

make key and cert 
```bash
openssl req -newkey rsa:2048 -nodes -keyout key.pem -x509 -days 365 -out cert.pem
```
test key
```bash
openssl x509 -text -noout -in cert.pem
```


Now run by giving tls option and supplying tls key and cer in path 
```bash
/home/ubuntu/sipp/sipp -d 80000 \
 -t l1 -tls_key key.pem -tls_cert cert.pem \
 -l 1 -r 1 -rtp_echo \
 -key MY_CALLER_NUMBER 10000000000 \
 -sf ./sipp-outbound-trunk-rtcp.xml \
 -m 1 \
 -s 919999999999 telcodomain.com  \
 -i 127.0.0.1 \
 -trace_err /
```


/root/sipp/sipp -d 80000  -s 919871204072 127.0.0.1 \
 -t l1 -tls_key /root/sipp/key.pem -tls_cert /root/sipp/cert.pem \
 -l 1 -r 1 -rtp_echo \
 -key MY_CALLER_NUMBER 10000000000 \
 -sf ./sipp-outbound-trunk-rtcp.xml \
 -m 1 \
 -i 127.0.0.1 \
 -trace_err 
 
## Debugging 

**Issue 1** : ERROR: connect_unix_sock: connect(/var/run/kamailio//kamailio_ctl): No such file or directory [2]
**Solution** : Look for the location of kamcmd executable in sbin like 
```
>ls /usr/local/sbin/
root@ip-10-130-74-151:/home/ubuntu# ls /usr/local/sbin/
kamailio  kamcmd  kamctl  kamdbctl
```
and execute from source 
```
/usr/local/sbin/kamcmd
```

**Issue 2** : ERROR: tls [tls_util.h:42]: tls_err_ret(): TLS accept:error:14094416:SSL routines:ssl3_read_bytes:sslv3 alert certificate unknown
ERROR: <core> [core/tcp_read.c:1505]: tcp_read_req(): ERROR: tcp_read_req: error reading - c: 0x7f0f56a3e440 r: 0x7f0f56a3e4c0 (-1)
**Solution :** although if verify_certificate is no , this should not affect the call, use openssl sclient to validate the certs . tbd more details   

**Issue 3** TLS error on sipp while using -t l1 option 
To use a TLS transport you must compile SIPp with OpenSSL
**solution**  look at instruction above to compile sipp from source instead of using readymate executables such as from brew 

**Issue 4** sipp build error  sipp/include/sipp.hpp:35:10: fatal error: 'netinet/sctp.h' file not found
**SOlution** 
include the scttp library 

**Issue 5** TLS_init_context: SSL_CTX_use_certificate_file failed
**Solution** use tls key and cert in path
```bash
sipp -sn uas -p 5077 -t l1 -tls_key key.pem  -tls_cert cert.pem  -i 127.0.0.1
```

**Issue 6** Unable to connect a TCP socket.
Use 'sipp -h' for details, errno = 107 (Transport endpoint is not connected)
and 
Failed to shutdown socket 7, errno = 107 (Transport endpoint is not connected)
**solution** 