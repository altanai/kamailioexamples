#  RTP engine integration and MOS scored in Kamailio LUA script

MOS(Mean Score Opinions) is terminology for audio, video and audiovisual quality expressions as per ITU-T P.800.1. It refers to listening, talking or conversational quality, whether they originate from subjective or objective models.

To read more on MOS score and Call metering - 
[VOIP CALL Metric Monitoring](https://telecom.altanai.com/2018/04/17/voip-call-metric-monitoring/)

MOS values on kamailio via RTPengine majorily contain 
mos - MOS value for the call , with range – 1.0 through 5.0.
packetloss - packetloss in percent present throughout the call.
jitter - variation in latency of packets ie jitter in milliseconds present throughout the call.
roundtrip - packet round-trip time in milliseconds present throughout the call.
samples -  number of samples used to determine the other MOS data points.

## Callflow 

UAC -> Kamailio SIP server -> UAS 

## Run 

Kamailio
```
kamailio -f kamailio_lua.cfg -Ee
```

RTPengine form config file 
```bash

```
or 
RTPengine form command line  
```baah
/home/altanai/rtpengine/daemon/rtpengine  --interface=192.168.1.111 --listen-ng=127.0.0.1:2222 -E
```

### RTPengine from dbtext
```
1:1:udp\:<ip>\:<port>:1:0:0
```

### UAC
simulate a UAC to send calls to Kamailio SIP server and RTP engine proxy
```bash
sipp -sf uac_rtcp.xml -d 80000 -s altanai <sipserverip:port> -i <uacip> -p <uacport>  -m 1 -rp 1 -max_retrans 1
```

### Dispatcher in kamailio

Add the destination details in dispatcher list on kamailip SIP sever
```bash
1 sip:<uasip:port> 0 0 0
```

### UAS
Simulate a UAS to receive calls from kamailio SIP server and RTP Engine rpoxy
```bash
sipp -sf uas_optonalACK.xml -i <uasip> -p <uasport> -trace_err -aa
```
-aa to automate handling of SIP INFO, OPTIONS, NOTIFY etc with 200 ok

## Installation 

Install Kamailio and related modules 

```
make include_modules="app_lua xmlrpc json nat rtpengine" cfg
sudo make all
sudo make install
```

## RTP Engine 

Set up the RTP engine to proxy media along with sip call flow .
[RTPEngine On Kamailio SIP server](https://telecom.altanai.com/2018/04/03/rtp-engine-on-kamailio-sip-server/)

Activate rtp engine module to store the mod valies in pvs 
```
modparam("rtpengine", "mos_max_pv", "$avp(mos_max)")
modparam("rtpengine", "mos_average_pv", "$avp(mos_average)")
modparam("rtpengine", "mos_min_pv", "$avp(mos_min)")

modparam("rtpengine", "mos_average_packetloss_pv", "$avp(mos_average_packetloss)")
modparam("rtpengine", "mos_average_jitter_pv", "$avp(mos_average_jitter)")
modparam("rtpengine", "mos_average_roundtrip_pv", "$avp(mos_average_roundtrip)")
modparam("rtpengine", "mos_average_samples_pv", "$avp(mos_average_samples)")

modparam("rtpengine", "mos_min_pv", "$avp(mos_min)")
modparam("rtpengine", "mos_min_at_pv", "$avp(mos_min_at)")
modparam("rtpengine", "mos_min_packetloss_pv", "$avp(mos_min_packetloss)")
modparam("rtpengine", "mos_min_jitter_pv", "$avp(mos_min_jitter)")
modparam("rtpengine", "mos_min_roundtrip_pv", "$avp(mos_min_roundtrip)")
```

### Call Leg labeling 

To store values specific to call legs use label attribute in rtpengine 
```
modparam("rtpengine", "mos_A_label_pv", "$avp(mos_A_label)")
modparam("rtpengine", "mos_average_packetloss_A_pv", "$avp(mos_average_packetloss_A)")
modparam("rtpengine", "mos_average_jitter_A_pv", "$avp(mos_average_jitter_A)")
modparam("rtpengine", "mos_average_roundtrip_A_pv", "$avp(mos_average_roundtrip_A)")
modparam("rtpengine", "mos_average_A_pv", "$avp(mos_average_A)")

modparam("rtpengine", "mos_B_label_pv", "$avp(mos_B_label)")
modparam("rtpengine", "mos_average_packetloss_B_pv", "$avp(mos_average_packetloss_B)")
modparam("rtpengine", "mos_average_jitter_B_pv", "$avp(mos_average_jitter_B)")
modparam("rtpengine", "mos_average_roundtrip_B_pv", "$avp(mos_average_roundtrip_B)")
modparam("rtpengine", "mos_average_B_pv", "$avp(mos_average_B)")
```

**conventions**

-- KSR - the new dynamic object exporting Kamailio functions (kemi)
-- sr - the old static object exporting Kamailio functions


## Debugging 

**isuee** ERROR: rtpengine [rtpengine.c:1766]: build_rtpp_socks(): Name or service not known

**solution**
```bash
id(int,auto) setid(int) url(string) weight(int) disabled(int) stamp(int)
1:1:udp\:192.168.1.109\:2222:1:0:0
```

**Ref** :

KEMI - https://kamailio.org/docs/tutorials/devel/kamailio-kemi-framework
RTPEngine module - https://kamailio.org/docs/modules/devel/modules/rtpengine.htm
Dispatcher module - https://www.kamailio.org/docs/modules/5.1.x/modules/dispatcher.html#dispatcher.f.ds_select_domain