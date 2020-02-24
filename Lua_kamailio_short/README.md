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