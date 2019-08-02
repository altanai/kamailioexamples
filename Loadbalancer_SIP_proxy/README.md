# Load balancer using dispatcher module 

Dispatcher module can be used as stateless load balancer 
Can choose one of many load balancing and traffic dispatching algorithms
requires the TM module if auto-discovery of active/inactive gateways is enabled 

load dispatcher module 
```
#!define WITH_LOADBALANCE
...
#!ifdef WITH_LOADBALANCE
loadmodule "dispatcher.so"
#!endif
```

## define module params 
```
#!ifdef WITH_LOADBALANCE
modparam("dispatcher", "db_url", DBURL)

modparam("dispatcher", "table_name", "dispatcher")
modparam("dispatcher", "flags", 2)
```

store all possible destinations in the AVP variable and if the selected destination fails, next one can be selected from the list.
* AVP_DST - varaible holds list with addresses and associated properties, in the seleceted order by dispatcher algorithm
* AVP_GRP - storing the group id of the destination set.
* AVP_CNT - storing the number of destination addresses kept in dst_avp AVPs.
* AVP_SOCK - hold the list with the sockets associated to the addresses stored in dst_avp avp.
```
modparam("dispatcher", "dst_avp", "$avp(AVP_DST)")
modparam("dispatcher", "grp_avp", "$avp(AVP_GRP)")
modparam("dispatcher", "cnt_avp", "$avp(AVP_CNT)")
modparam("dispatcher", "sock_avp", "$avp(AVP_SOCK)")

```
to enable balance alg. no. 10
dsdstid - storing the destination unique ID used for call load based dispatching.
ds_hash_size - power of two to set the number of slots to hash table storing data for call load dispatching 
```
#modparam("dispatcher", "dstid_avp", "$avp(dsdstid)")
#modparam("dispatcher", "ds_hash_size", 8)
```
pings 
send ping to inactive gateways to detect if they are up now . 
ping the servers every 10 seconds and use the "sip:keepalive@voiptelco.com" uri in the contact.
ping reply code - specifying how the media server can respond to the keepalive and not be considered down
set to 0 to disbale the ping feature
```
modparam("dispatcher", "ds_ping_interval", 20)
modparam("dispatcher", "ds_ping_from", "sip:keepalive@voiptelco.com")
#modparam("dispatcher", "ds_ping_method", "INFO")
modparam("dispatcher", "ds_ping_reply_codes", "class=2;code=480;code=404")
```
probe
Controls what gateways are tested to see if they are reachable.
Value 0: If set to 0, only the gateways with state PROBING are tested. After a gateway is probed, the PROBING state is cleared in this mode.
Value 1: If set to 1, all gateways are tested. If set to 1 and there is a failure of keepalive to an active gateway, then it is set to TRYING state.
Value 2: if set to 2, only gateways in inactive state with probing mode set are tested.
Value 3: If set to 3, any gateway with state PROBING is continually probed without modifying/removing the PROBING state. This allows selected gateways to be probed continually, regardless of state changes.
probing threhold - how many keepalive messages can fail before the destination is considered down.
```
modparam("dispatcher", "ds_probing_mode", 1)
modparam("dispatcher", "ds_probing_threshhold", 1)
```

configure codes or classes of SIP replies to list only allowed replies (i.e. when temporarily unavailable=480)
```
modparam("dispatcher", "ds_ping_reply_codes", "class=2;code=480;code=404")
```
flags
 0 (value 1) - inactive destination; 
 1 (value 2) - temporary trying destination (in the way to become inactive if it does not reply to keepalives - there is a module parameter to set the threshold of failures); 
 2 (value 4) - admin disabled destination; 
 3 (value 8) - probing destination (sending keep alives);
```
modparam("dispatcher", "flags", 2)
```

## configure the latency estimator
modparam("dispatcher", "ds_latency_estimator_alpha", 900)
control the memory of the estimator EWMA "exponential weighted moving average"
EWMA - statistic for monitoring the process that averages the data in a way that gives less and less weight to data as they are further removed in time. ref : https://www.itl.nist.gov/div898/handbook/pmc/section3/pmc324.htm


## Call routing via request route 

can customize the condition for doing load balancig on any term like request uri checking, specific header checking, etc. and can specifiy regular location based routing in else 
```
#!ifdef WITH_LOADBALANCE
if (<CALL IS DESTINED FOR THE MEDIA SERVICES>)
{
  #we go to the load balancer route
  route(LOADBALANCE);
}
else
{
  #we perform normal usrloc lookup for the call
  route(LOCATION);
}
#!else
# user location service
route(LOCATION);
#!endif
```

## load balance route

ds_select_dst(destination_set, algorithm) function chooses the destination for the call . Options of algorithms can be 
Alg. 0 is the default one that does the the choosing over the call ID hash
Alg. 4 is a Round-Robin
Alg. 10 is the one that chooses the destination based on the minimum load of all destinations etc

if ds_select_dst false then that means no destination is available. We notify the user by 404 and exit the script.
else selected address is set to dst_uri field (aka the outbound proxy address or the $du variable), and call proceeds
```
#!ifdef WITH_LOADBALANCE
route[LOADBALANCE1] {
        if(!ds_select_dst("0", "4"))
        {
                xlog("L_NOTICE", "No destination available!");
                send_reply("404", "No destination");
                exit;
        }
        xlog("L_DEBUG", "Routing call to <$ru> via <$du>\n");
        t_set_fr(0,2000);
        t_on_failure("MANAGE_FAILURE");
        return;
}
#!endif
```
t_set_fr - set the no_reply_recieved timeout to 2 second 
if the selected server fails to respond within 2 seconds the failure_route "MANAGE_FAILURE" is called


## manage failure routing cases
handles failures for routing 
mark the destination just tried with Inactive and Probing using ds_mark_dst()
which can mark the last used address from destination set as 
inactive ("i"/"I"), 
active ("a"/"A"), 
disabled ("d"/"D") or 
trying ("t"/"T").
Can exit or since one server $du failed to answer, selecting new one ( ds_next_dst()) and try again 
set local timeout (t_set_fr) for new one or check if that one returns 500 reply , then call manage_failure again to try another destination
If there are no more destinations to try , reply 404 No destination to client
```
failure_route[MANAGE_FAILURE] {
        route(NATMANAGE);
        if (t_is_canceled()) {
                exit;
        }
#!ifdef WITH_LOADBALANCE
        if (t_check_status("500") || t_branch_timeout() || !t_branch_replied())
        {
                ds_mark_dst("ip");
                if(ds_next_dst())
                {
                        t_set_fr(0,2000);
                        t_on_failure("MANAGE_FAILURE");
                        route(RELAY);
                        exit;
                }
                else
                {
                        send_reply("404", "No destination");
                        exit;
                }
        }
#!endif
}
```

## Dispatcher syntax 

```
setid(int) destination(sip uri) flags(int,opt) priority(int,opt) attrs(str,opt)
```
special attributes :
duid - uniquely identify a destination (gateway address)
maxload - upper limit of active calls per destination. When the limit is reached, then the gateway is no longer selected for new calls until an exiting call via that gateway is terminated. If set to 0, then no active call limit is used.
weight - percent of calls to be sent to that gateways(0-100)
rweight - relative weight based load distribution (0-100)
socket - sending the SIP traffic as well as OPTIONS keepalives.
ping_from - set the From URI in OPTIONS keepalives. It overwrites the general ds_ping_from parameter.

Example : 
1 sip:127.0.0.1:5080 0 0 duid=abc;socket=udp:x.x.x.x:5060;my=xyz;ping_from=sip:myproxy.com

Ref:
kamailio sample dispatcher module based config - http://kamailio.org/docs/modules/stable/modules/dispatcher.html#dispatcher.ex.config