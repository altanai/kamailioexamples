# Kamailio as Session Border Control 
 
 Features 
 Auth is the destination gateway challenges with 407 proxy authetication required 

## Debugging 

**Issue1** Kamailio itself generating 487 request timeout 
**Solution** Auth involves reinvote and auth itself can take some time , I suggest to keet the values of fr_timer and fr_inv_timer high such as 
```
modparam("tm", "fr_timer", 10000)
modparam("tm", "fr_inv_timer", 180000)
```

## Debugging 

**Issue**  while runing sipp script sipp -sf sipp_auth_uas.xml -p 5077 -trace_msg -trace_err -t tn
Authentication requires OpenSSL support!.
**Solution** compile sipp from tar from repo like https://github.com/SIPp/sipp/releases/tag/v3.6.0
```
sudo apt-get install libssl-dev libpcap-dev
./configure --with-openssl
make
```

**Issue2** tcpconn_1st_send(): connect ip:5077 failed (RST) Connection refused
tcpconn_1st_send(): ip:5077: connect & send  for 0x7fa67ed1bd08 failed: Connection refused (111)
tm [../../core/forward.h:251]: msg_send_buffer(): tcp_send failed
tm [t_fwd.c:1567]: t_send_branch(): sending request on branch 0 failed
sr_kemi_core_log(): 99140ZGFlNjA1ZGEzODRkMmQ0ZTNlNmJlNWVkM2UwMThkODU|udp:ip:5060|INVITE|sip meesage not relayed
sl [sl_funcs.c:362]: sl_reply_error(): stateless error reply used: Unfortunately error on sending to next hop occurred (477/SL)