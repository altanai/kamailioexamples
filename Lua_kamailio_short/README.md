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

**Issue1** lua.h: No such file or directory 
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

**Issue 6** 
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