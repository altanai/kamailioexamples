# Link Two RTP Engines by Daisyy 

Ensure you have added two RTP engines in rtpengine list file 

```bash
id(int,auto) setid(int) url(string) weight(int) disabled(int) stamp(int)
1:1:udp\:<rtpengine_ip1>\:2222:1:0:0
2:2:udp\:1<rtpengine_ip2>\:2222:1:0:0
```

Ensure you have both the RTP engines loaded 
```bash
kamcmd -s tcp:<appserver_ip>:2046 rtpengine.show all
```
The outout of this should be 
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
**solution** Look up if dispatchers is successfull added , also checked is dispatcher destination is responsing to OPTIONS keepalive pings 
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

**Issue 4** src/utils/kamutils.lua:5: module 'cjson' not found:
\
**solution** Install cjson using luarocks
```bash
luarocks install lua-cjson
```
If you further get 
```bash
Installing https://luarocks.org/lua-cjson-2.1.0.6-1.src.rock
gcc -O2 -fPIC -I/usr/include/lua5.2 -c lua_cjson.c -o lua_cjson.o
lua_cjson.c:43:10: fatal error: lua.h: No such file or directory
 #include <lua.h>
          ^~~~~~~
compilation terminated.

Error: Build error: Failed compiling object lua_cjson.o

```
then ensure you have both lua and lua dev libs 
```bash
sudo apt-get install liblua5.2 liblua5.2-dev
```

Note : Often there may be version mismatch between lua5.1 and lua 5.3 
in which case the path for seraching cjson.o will mismatch such as  installversion 5.2 but program look in path for 5.1
```bash
module 'cjson' not found:
	no field package.preload['cjson']
	no file './cjson.lua'
	no file '/usr/local/share/lua/5.1/cjson.lua'
	no file '/usr/local/share/lua/5.1/cjson/init.lua'
	no file '/usr/local/lib/lua/5.1/cjson.lua'
	no file '/usr/local/lib/lua/5.1/cjson/init.lua'
	no file '/usr/share/lua/5.1/cjson.lua'
	no file '/usr/share/lua/5.1/cjson/init.lua'
	no file '/home/ubuntu/zentrunk-app-server/zen-trunk/src/cjson.lua'
	no file '/home/ubuntu/zentrunk-app-server/zen-trunk/src/utils/cjson.lua'
	no file '/home/ubuntu/zentrunk-app-server/zen-trunk/src/core/cjson.lua'
	no file '/etc/kamailio/cjson.lua'
	no file '/etc/kamailio/utils/cjson.lua'
	no file '/etc/kamailio/cjson.lua'
	no file '/etc/kamailio/utils/cjson.lua'
	no file '/etc/kamailio/core/cjson.lua'
	no file '../../zen-trunk/src/cjson.lua'
	no file '../../zen-trunk/src/utils/cjson.lua'
	no file '../../zen-trunk/src/core/cjson.lua'
	no file './cjson.so'
	no file '/usr/local/lib/lua/5.1/cjson.so'
	no file '/usr/lib/x86_64-linux-gnu/lua/5.1/cjson.so'
	no file '/usr/lib/lua/5.1/cjson.so'
	no file '/usr/local/lib/lua/5.1/loadall.so'
```
in such as case it is best to either use some version control manager like luaver or ditch the current lua and reinstall 

Do not try to repeat my mistake of creating softlink or copy source  between version 5.2 and 5.1 
```bash
  cp -r /usr/local/share/lua/5.2/ /usr/local/share/lua/5.1/
```
which will create even more issues later 
```bash
12(5499) ERROR: app_lua [app_lua_api.c:326]: lua_sr_init_child(): error from Lua: error loading module 'cjson' from file '/usr/local/lib/lua/5.1/cjson.so':
	/usr/local/lib/lua/5.1/cjson.so: undefined symbol: luaL_setfuncs
```

Also you can use the modules directly instead of installing via luarocks 
```bash
sudo apt get install lua-cjson
``` 