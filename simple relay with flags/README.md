# Simple Relay SIP server 

## common configuration errors

```sh
 0(24666) ERROR: tm [t_reply.c:493]: _reply_light(): cannot allocate shmem buffer
 0(24666) ERROR: <core> [core/msg_translator.c:2187]: build_req_buf_from_sip_req(): out of memory
 0(24666) ERROR: tm [t_fwd.c:476]: prepare_new_uac(): could not build request
 0(24666) ERROR: tm [t_fwd.c:1735]: t_forward_nonack(): failure to add branches
 0(24666) ERROR: tm [t_reply.c:493]: _reply_light(): cannot allocate shmem buffer
 0(24666) ERROR: tm [t_lookup.c:1512]: t_unref(): generation of a delayed stateful reply failed
 0(24666) NOTICE: <script>: message received
 0(24666) ERROR: <core> [core/msg_translator.c:2187]: build_req_buf_from_sip_req(): out of memory
```

```sh
 0(24666) ERROR: <core> [core/mem/q_malloc.c:291]: qm_find_free(): qm_find_free(0x7f9d76747000, 21480); Free fragment not found!
 0(24666) ERROR: <core> [core/mem/q_malloc.c:425]: qm_malloc(): qm_malloc(0x7f9d76747000, 21480) called from core: core/sip_msg_clone.c: sip_msg_shm_clone(496), module: core; Free fragment not found!
 0(24666) ERROR: <core> [core/sip_msg_clone.c:499]: sip_msg_shm_clone(): cannot allocate memory
 0(24666) ERROR: tm [t_reply.c:860]: fake_req(): failed to clone the request
 0(24666) ERROR: tm [t_reply.c:981]: run_failure_handlers(): fake_req failed
```

```sh
 0(24666) ERROR: <core> [core/mem/q_malloc.c:291]: qm_find_free(): qm_find_free(0x7f9d76747000, 24288); Free fragment not found!
 0(24666) ERROR: <core> [core/mem/q_malloc.c:425]: qm_malloc(): qm_malloc(0x7f9d76747000, 24288) called from tm: t_msgbuilder.c: build_local_reparse(345), module: tm; Free fragment not found!
 0(24666) ERROR: tm [t_msgbuilder.c:348]: build_local_reparse(): cannot allocate shared memory
 0(24666) ERROR: tm [t_msgbuilder.c:520]: build_local_reparse(): cannot build ACK request
```

solution : check the public , private address in listen 
```
listen = MY_UDP_ADDR advertise MY_EXTERNAL_IP:MY_UDP_PORT
listen = MY_TCP_ADDR advertise MY_EXTERNAL_IP:MY_TCP_PORT
```

```sh
 0(5316) ERROR: <core> [core/pvapi.c:903]: pv_parse_spec2(): error searching pvar "rm"
 0(5316) ERROR: <core> [core/pvapi.c:1107]: pv_parse_spec2(): wrong char [m/109] in [$rm] at [2 (0)]
 0(5316) ERROR: xlog [xlog.c:513]: xdbg_fixup_helper(): wrong format[ method ($rm) r-uri ($ru) form $fu ]
```
**solution** : if you are using xlog to print psuedu varoable make sure the pv and xlog module are loaded and in correct order such as 
```

loadmodule "tm.so"
loadmodule "sl.so"
loadmodule "rr.so"
loadmodule "pv.so"
...
loadmodule "xlog.so"
```


## Make Calls 

make call between 2 sip User agents. 

agent 1 : Bria using SIP port 5068 , auto ICE on
username : 888 
Bria\x203 62707 altanaibisht   21u  IPv4 0x252377c03238fc13      0t0  UDP *:54599
Bria\x203 62707 altanaibisht   23u  IPv4 0x252377c04ca04b73      0t0  UDP *:5068
Bria\x203 62707 altanaibisht   24u  IPv4 0x252377c047070bbb      0t0  TCP *:5068 (LISTEN)
Bria\x203 62707 altanaibisht   26u  IPv4 0x252377c032b34653      0t0  UDP *:51588
Bria\x203 62707 altanaibisht   27u  IPv4 0x252377c032b39273      0t0  UDP *:59013
Bria\x203 62707 altanaibisht   30u  IPv4 0x252377c0330653eb      0t0  UDP *:54083
Bria\x203 62707 altanaibisht   33u  IPv4 0x252377c033067cb3      0t0  UDP *:52721
Bria\x203 62707 altanaibisht   37u  IPv4 0x252377c032b33b73      0t0  UDP *:55743
Bria\x203 62707 altanaibisht   38u  IPv4 0x252377c040a6823b      0t0  TCP *:i-net-2000-npr (LISTEN)
Bria\x203 62707 altanaibisht   39u  IPv4 0x252377c032b38a4b      0t0  UDP *:53504
Bria\x203 62707 altanaibisht   40u  IPv4 0x252377c032b35c13      0t0  UDP *:54840
Bria\x203 62707 altanaibisht   41u  IPv4 0x252377c04ca0695b      0t0  UDP *:49513
Bria\x203 62707 altanaibisht   42u  IPv4 0x252377c04ca081d3      0t0  UDP *:58363
Bria\x203 62707 altanaibisht   43u  IPv4 0x252377c04ca08743      0t0  UDP *:52241
Bria\x203 62707 altanaibisht   44u  IPv4 0x252377c0323924db      0t0  UDP *:60248
Bria\x203 62707 altanaibisht   45u  IPv4 0x252377c032392223      0t0  UDP *:62027
Bria\x203 62707 altanaibisht   46u  IPv4 0x252377c03238ebc3      0t0  UDP *:50783
Bria\x203 62707 altanaibisht   47u  IPv4 0x252377c04ca08f6b      0t0  UDP *:58418
Bria\x203 62707 altanaibisht   49u  IPv4 0x252377c045591bbb      0t0  TCP 192.168.1.120:60085->ec2-x-x-x-x.compute-1.amazonaws.com:http (ESTABLISHED)


agent 2 acting as callee  : Xlite using SIP port 5067 , auto ICE on
username : 666
X-Lite    59681 altanaibisht   35u  IPv4 0x252377c03b3ebbbb      0t0  TCP localhost:dynamid (LISTEN)
X-Lite    59681 altanaibisht   52u  IPv4 0x252377c04ca09d03      0t0  UDP *:authentx
X-Lite    59681 altanaibisht   55u  IPv4 0x252377c04559123b      0t0  TCP *:authentx (LISTEN)
X-Lite    59681 altanaibisht   66u  IPv4 0x252377c044e6323b      0t0  TCP 192.168.1.120:52533->x-x-x-x:https (CLOSED)



### Note :
* make sure all modules that need tm module are loaded after tm in the configuration file
* since we are not using Register , make sure the callee is listening on accessible ip and port for the  kamailio proxy server 