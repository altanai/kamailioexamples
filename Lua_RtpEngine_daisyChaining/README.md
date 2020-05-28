# Link Two RTP Engines by Daisyy 

Ensure you have added two RTP engines in rtpengine list file 

```bash
id(int,auto) setid(int) url(string) weight(int) disabled(int) stamp(int)
1:1:udp\:<rtpengine_ip1>\:2222:1:0:0
2:2:udp\:1<rtpengine_ip2>\:2222:1:0:0
```

Ensure you have bothe the RTP engines loaded 
```bash
kamcmd -s tcp:<appserver_ip>:2046 rtpengine.show all
```
The output of this should be 
```bash
{
	url: udp:<rtpengine_ip1>:2222
	set: 1
	index: 0
	weight: 1
	disabled: 0
	recheck_ticks: 0
}
{
	url: udp:<rtpengine_ip2>:2222
	set: 1
	index: 0
	weight: 1
	disabled: 0
	recheck_ticks: 0
}
```
### debugging 

**Issue1** ERROR: connect_unix_sock: connect(/var/run/kamailio//kamailio_ctl): No such file or directory [2]
**Solution** ensure the ctl modules is used and connectred to correct ip of app server 
```bash
 loadmodule "ctl.so"
...
# ----- ctl ------
 modparam("ctl", "binrpc", "tcp:<ip>:2046")
```
and use server address while using kamcmd 
```bash
kamcmd -s tcp:<appserver_ip>:2046 app_lua.reload 0
```

You can use either 

1. set_rtp_engine_set(r1,r2)

or 

2. rtpengine_set(r) twice 

**Issue2** Dispatcher not Found
**solution** Look up if dispatchers is sucecsfull added , also checked is dispatcher detaination is reposning to OPTIONS keepalive pings 
```bash
kamcmd -s tcp:<appserver_ip>:2046 dispatcher.list   
{
	NRSETS: 1
	RECORDS: {
		SET: {
			ID: 1
			TARGETS: {
				DEST: {
					URI: sip:<destination_ip>:5080
					FLAGS: IP
					PRIORITY: 0
					ATTRS: {
						BODY: 0
						DUID: 
						MAXLOAD: 0
						WEIGHT: 0
						RWEIGHT: 0
						SOCKET: 
					}
				}
			}
		}
	}
}
```
You cna also reload the dispatcher 
```bash
kamcmd -s tcp:<appserver_ip>:2046 dispatcher.reload
```

**Issue 3** CTL module not connecting  
```bash
 0(23404) ERROR: ctl [init_socks.c:210]: init_tcpudp_sock(): ERROR: init_tcpudp_sock: bind: Cannot assign requested address [99]
 0(23404) ERROR: ctl [ctl.c:291]: mod_init(): ERROR: ctl: mod_init: init ctrl. sockets failed
 0(23404) ERROR: <core> [core/sr_module.c:911]: init_mod(): Error while initializing module ctl (/usr/local/lib64/kamailio/modules/ctl.so)
```
\
**solution** check whether the IP address is  prohibited with correct IP and port 
```bash
 modparam("ctl", "binrpc", "tcp:192.168.1.111:2046")
```
or define using substitute string like 
```bash
#!substdef "!MY_IP_ADDR!192.168.1.111!g"
#!substdef "!MY_CTL_ADDR!tcp:MY_IP_ADDR:2046!g"
...
modparam("ctl", "binrpc", MY_CTL_ADDR)
```
