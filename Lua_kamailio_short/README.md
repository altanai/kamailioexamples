# kamailio Basic routing proxy using LUA programming language

sip US --> Kamailio (5060) --> sipp UAS (5080)

Note : Management Interface () mi_fifo and mi_rpc ) are depricated post v 5.x hence reoved from the sample 
ref : https://stackoverflow.com/questions/42928541/can-not-find-mi-fifo-so-and-mi-rpc-so-files-while-install-kamailio-on-sierra

sipp server 
sipp -sn uas 127.0.0.1 -p 5080

-- KSR - the new dynamic object exporting Kamailio functions (kemi)
-- sr - the old static object exporting Kamailio function

## Lua KEMI (Kamailio Embedded Interface) Interpreter

lightweight, embeddable scripting language
open-source software, MIT licensed 
procedural, object-oriented, functional, data-driven
procedural syntax with data description constructs
works on associative arrays and extensible semantic
meta-mechanisms for implementing classes and inheritance
interprets bytecode with a register-based virtual machine
automatic memory management with incremental garbage collection
hot reload of routing rules  and Dynamic Data pushed back 

Lua interpreter is linked from liblua library in app_lua module.
LuaJIT is an independent implementation of Lua using a just-in-time compiler

```
//loading 
loadmodule "app_lua.so"

//script path
modparam("app_lua", "load", "route.lua")

//specifying engine
cfgengine "lua"
```

## Predefined functions in app_lua module

Example
```
function ksr_request_route()
    KSR.info("===== request - from kamailio lua script\n");
    if KSR.maxfwd.process_maxfwd(10) < 0 then
        KSR.sl.send_reply(483, "Too Many Hops");
        return;
    end
    //KSR.sl.sreply(200, "OK Lua");
    KSR.pv.sets("$du", "sip:127.0.0.1:5080")
    KSR.tm.t_on_branch("ksr_branch_route_one");
    KSR.tm.t_on_reply("ksr_onreply_route_one");
    KSR.tm.t_on_failure("ksr_failure_route_one");
    if KSR.tm.t_relay() < 0 then
        KSR.sl.send_reply(500, "Server error")
    end
end

function ksr_reply_route()
    KSR.info("===== response - from kamailio lua script\n");
end

function ksr_branch_route_one()
    KSR.info("===== branch route - from kamailio lua script\n");
end

function ksr_onreply_route_one()
    KSR.info("===== onreply route - from kamailio lua script\n");
end

function ksr_failure_route_one()
    KSR.info("===== failure route - from kamailio lua script\n");
end
```


## Debugging 

**Issue1** Failing to build module app_lua with lua.h: No such file or directory 
```bash
CC (gcc) [M app_lua.so]		app_lua_mod.o
In file included from app_lua_mod.c:32:0:
app_lua_api.h:25:10: fatal error: lua.h: No such file or directory
 #include <lua.h>
          ^~~~~~~
compilation terminated.
../../Makefile.rules:100: recipe for target 'app_lua_mod.o' failed
```
\
**Solution** install lua lib files 
```bash
sudo apt install luarocks
sudo apt-get install lua5.2
sudo apt-get install libprotobuf-dev protobuf-compiler
luarocks install loadcaffe
```
Then to build the lua module goto /kamailio_sourcecodefolder/src/modules/app_lua
and run
```bash
 sudo make && make install 
```

**Issue2** Event.h not found 
```bash
CC (gcc) [M http_async_client.so]		async_http.o
async_http.c:42:10: fatal error: event2/event.h: No such file or directory
 #include <event2/event.h>
          ^~~~~~~~~~~~~~~~
compilation terminated.
../../Makefile.rules:100: recipe for target 'async_http.o' failed
```
**Solution**
```bash
apt-get install libevent-dev
```

**Issue 3** curl.h: No such file or directory
```bash
CC (gcc) [M http_async_client.so]		async_http.o
In file included from async_http.c:53:0:
async_http.h:43:10: fatal error: curl/curl.h: No such file or directory
 #include <curl/curl.h>
          ^~~~~~~~~~~~~
compilation terminated.
../../Makefile.rules:100: recipe for target 'async_http.o' failed
``` 
\
**Solution** Install lib curl
```bash
sudo apt-get install libcurl4-openssl-dev
```

**Issue 4** xmlreader.h: No such file or directory
```bash
CC (gcc) [M xmlrpc.so]		xmlrpc.o
xmlrpc.c:50:10: fatal error: libxml/xmlreader.h: No such file or directory
 #include <libxml/xmlreader.h>
          ^~~~~~~~~~~~~~~~~~~~
compilation terminated.
../../Makefile.rules:100: recipe for target 'xmlrpc.o' failed
```
\
**Solution** install xml dev
```bash
sudo apt-get install libxml2-dev libxslt-dev
``` 

**Issue 5** uuid.h: No such file or directory
```bash
CC (gcc) [M uuid.so]		uuid_mod.o
uuid_mod.c:28:10: fatal error: uuid/uuid.h: No such file or directory
 #include <uuid/uuid.h>
          ^~~~~~~~~~~~~
compilation terminated.
../../Makefile.rules:100: recipe for target 'uuid_mod.o' failed
make[2]: *** [uuid_mod.o] Error 1
```
\
**Solution** Install uuid dev lib
```bash
apt-get install uuid-dev
```

**Issue 6** Failing to build module json
```bash
CC (gcc) [M jsonrpcc.so]		jsonrpc_io.o
In file included from jsonrpc_io.c:41:0:
jsonrpc.h:32:10: fatal error: json.h: No such file or directory
 #include <json.h>
          ^~~~~~~~
compilation terminated.
../../Makefile.rules:100: recipe for target 'jsonrpc_io.o' failed
make[2]: *** [jsonrpc_io.o] Error 1
```
**Solution** json RPC install
```bash
sudo apt install libjsoncpp-dev libjson-c-dev
```

**Issue 7** jansson.h: No such file or directory
```bash
CC (gcc) [M jansson.so]		jansson_path.o
jansson_path.c:16:10: fatal error: jansson.h: No such file or directory
 #include <jansson.h>
          ^~~~~~~~~~~
compilation terminated.
../../Makefile.rules:100: recipe for target 'jansson_path.o' failed
make[2]: *** [jansson_path.o] Error 1
```
\
**solution** install janson 
```bash
apt install jansondev
```

**Issue 8** sqlite3.h: No such file or directory
```bash
db_sqlite.c:26:10: fatal error: sqlite3.h: No such file or directory
 #include <sqlite3.h>
          ^~~~~~~~~~~
compilation terminated.
../../Makefile.rules:100: recipe for target 'db_sqlite.o' failed
make[2]: *** [db_sqlite.o] Error 1
```
**solution** install sqlite3 
```bash

```

**Issue 9** proiblem in modules install , for exmaple secfilter not found 
```bash
module not found: modules/secfilter
Makefile:511: recipe for target 'modules' failed
make[1]: *** [modules] Error 1
make[1]: Leaving directory '/home/altanai/kamailio/src'
Makefile:27: recipe for target 'modules' failed
make: *** [modules] Error 2
```
\
**solution** exclude unwanted modules via cmd install if not exlcusively present in modules.lst
```bash
sudo make modules include_modules="app_lua json" exclude_modules="secfilter"
```

Also ins case of app_mono
```bash
In file included from app_mono_api.c:35:0:
app_mono_api.h:27:10: fatal error: mono/jit/jit.h: No such file or directory
 #include <mono/jit/jit.h>
          ^~~~~~~~~~~~~~~~
compilation terminated.
../../Makefile.rules:100: recipe for target 'app_mono_api.o' failed
make[2]: *** [app_mono_api.o] Error 1
Makefile:511: recipe for target 'modules' failed
make[1]: *** [modules] Error 1
```
or for geoip or pther unrealted mod 
```bash
sudo make modules include_modules="app_lua json" exclude_modules="secfilter acc_json acc_radius app_java app_mono app_perl app_python app_python3 app_ruby auth_ephemeral auth_identity auth_radius cdp cdp_avp cnxcc cplc crypto db2_ldap db_berkeley db_cassandra db_mongodb db_mysql db_oracle db_perlvdb db_postgres db_redis db_sqlite db_unixodbc dialplan dnssec erlang evapi geoip geoip2 gzcompress h350 http_async_client http_client ims_auth ims_charging ims_dialog ims_diameter_server ims_icscf ims_ipsec_pcscf ims_isc ims_ocs ims_qos ims_registrar_pcscf ims_registrar_scscf ims_usrloc_pcscf ims_usrloc_scscf jansson janssonrpcc jsonrpcc kazoo lcr ldap log_systemd memcached misc_radius ndb_cassandra ndb_mongodb ndb_redis nsq osp outbound peering phonenum presence presence_conference presence_dialoginfo presence_mwi presence_profile presence_reginfo presence_xml pua pua_bla pua_dialoginfo pua_json pua_reginfo pua_rpc pua_usrloc pua_xmpp rabbitmq regex rls rtp_media_server sctp snmpstats tls topos_redis utils uuid websocket xcap_client xcap_server xhttp_pi xmlops xmlrpc xmpp "
```

exclude it from modules 
```bash
sudo make modules include_modules="app_lua json" exclude_modules="secfilter app_mono"
```

**issue 10 ** rabbit mq not installing 
```bash
kz_amqp.h:35:10: fatal error: amqp.h: No such file or directory
 #include <amqp.h>
          ^~~~~~~~
compilation terminated.
../../Makefile.rules:100: recipe for target 'kz_trans.o' failed
make[2]: *** [kz_trans.o] Error 1
```
\
**solution** install librabitmq-dev package
```bash
sudo apt install librabbitmq-dev
```
