# Kamailio as Load balancer 

Uses dipatch module with dbtext to stateless proxy sip traffic to sip servers 
Use dbtext to stpres destinations 

Read More on employing kamailio as SIP call Load balancer here : 
https://telecom.altanai.com/2014/11/12/telephony-solutions-with-kamailio/

> Among other features it offers load balancing with many distribution algorithms and failover support , 
>flexible least cost routing , routing failover and replication for High Availability (HA).

## security against DOS ( denial of service ) attacks

sample pike module in action
```
INFO: <script>: REGISTER from sip:altanai@10.10.10.10 (IP:10.20.20.20:44133)
 REGISTER from sip:altanai@10.10.10.10 (IP:10.10.10.10:5060)
 REGISTER from sip:altanai@10.10.10.10 (IP:10.10.10.10:5060)
 REGISTER from sip:altanai@10.10.10.10 (IP:10.10.10.10:5060)
 REGISTER from sip:altanai@10.10.10.10 (IP:10.10.10.10:5060)
 REGISTER from sip:altanai@10.10.10.10 (IP:10.10.10.10:5060)
 REGISTER from sip:altanai@10.10.10.10 (IP:10.10.10.10:5060)
 REGISTER from sip:altanai@10.10.10.10 (IP:10.10.10.10:5060)
 WARNING: pike [pike_funcs.c:151]: pike_check_req(): PIKE - BLOCKing ip 10.10.10.10, node=0x7f7e073f7dd0
 ALERT: pike blocking REGISTER from sip:altanai@10.10.10.10 (IP:10.10.10.10:5060)
 REGISTER from sip:altanai@10.10.10.10 (IP:10.20.20.20:44133)
 REGISTER from sip:altanai@10.10.10.10 (IP:10.20.20.20:44133)
``` 
unlcoking 
```
 pike [pike_funcs.c:278]: refresh_node(): PIKE - UNBLOCKing node 0x7f7e073f7dd0
 REGISTER from sip:altanai@10.10.10.10 (IP:10.20.20.20:44133)
```

## checking traffic using ngrep
```
> ngrep -W byline -d any port 5060 -q
```

## Dispatcher 


Dispatcher module - https://www.kamailio.org/docs/modules/5.1.x/modules/dispatcher.html#dispatcher.f.ds_select_domain