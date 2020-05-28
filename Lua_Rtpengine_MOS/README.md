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
```
kamailio -f kamailio_lua.cfg -Ee
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

output 
```bash
 4(15674) INFO: <core> [core/kemi.c:150]: sr_kemi_core_log():  mos avg 4.4 
 4(15674) INFO: <core> [core/kemi.c:150]: sr_kemi_core_log():  mos max 4.4 
 4(15674) INFO: <core> [core/kemi.c:150]: sr_kemi_core_log():  mos min 4.4 
 4(15674) INFO: <core> [core/kemi.c:150]: sr_kemi_core_log(): mos_average_packetloss_pv0 
 4(15674) INFO: <core> [core/kemi.c:150]: sr_kemi_core_log(): mos_average_jitter_pv0 
 4(15674) INFO: <core> [core/kemi.c:150]: sr_kemi_core_log(): mos_average_roundtrip_pv2771 
 4(15674) INFO: <core> [core/kemi.c:150]: sr_kemi_core_log(): mos_average_samples_pv2 
 4(15674) INFO: <core> [core/kemi.c:150]: sr_kemi_core_log(): mos_min_pv4.4 
 4(15674) INFO: <core> [core/kemi.c:150]: sr_kemi_core_log(): mos_min_at_pv0:05 
 4(15674) INFO: <core> [core/kemi.c:150]: sr_kemi_core_log(): mos_min_packetloss_pv0 
 4(15674) INFO: <core> [core/kemi.c:150]: sr_kemi_core_log(): mos_min_jitter_pv0 
 4(15674) INFO: <core> [core/kemi.c:150]: sr_kemi_core_log(): mos_min_roundtrip_pv2776 
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

**Issue1** Unable to select RTPengine from table
```bash
select_rtpp_set(): no rtpp_set_list->rset_first
```
\
**Solution** I am using dbtext databse and rtpengine as tables name as 
initially had only 1 entry 
```bash
id(int,auto) setid(int) url(string) weight(int) disabled(int) stamp(int)
1:1:udp\:192.168.1.109\:2222:1:0:0
```
adding one more , i was able to workaround it
```bash
id(int,auto) setid(int) url(string) weight(int) disabled(int) stamp(int)
1:1:udp\:192.168.1.109\:2222:1:0:0
2:1:udp\:192.168.1.109\:2222:1:0:0
```
ofcourse dont foegt to reload using cli command
```bash
kamcmd -s tcp:127.0.0.1:2046 rtpengine.reload 
```
and validate that it has been added 
```bash
>kamcmd -s tcp:127.0.0.1:2046 rtpengine.show all
{
        url: udp:192.168.1.109:2222
        set: 1
        index: 0
        weight: 1
        disabled: 0
        recheck_ticks: 0
}
```

**Issue2** Running out of ports
```bash
rtpp_function_call(): proxy replied with error: Ran out of ports
```
**solution** Remeber to monitopr your active calls on RTPengine 
Also call rtpengine_delete  to end calls exclusively on end dialog requests such as BYE 
```bash
    if request_method == "BYE" then
        KSR.rtpengine.rtpengine_delete0()
        ...
```

**Issue3** Missing labels for both sided legs
```bash
4(8466) ERROR: <core> [core/pvapi.c:121]: pv_locate_name(): missing pv marker [mos_A_label]
```
\
**solution** set the label 
config
```bash
modparam("rtpengine", "mos_A_label_pv", "$avp(mos_A_label)")
modparam("rtpengine", "mos_B_label_pv", "$avp(mos_B_label)")
```
and in lua code 
```bash
KSR.pv.sets("$avp(mos_A_label)", "Aleg_label");
KSR.pv.sets("$avp(mos_B_label)", "Bleg_label");
```

**Issue4**  attempt to concatenate a nil value on mos score of othet emdia stats Pv values
\
**solution** Instead of using KSR.pv.get to fetch values which would return nil when RTCP did not happen
or RTPengine did not populate the ms score 
use getvn with default of 0 
```bash
KSR.log("info", " mos avg " .. KSR.pv.getvn("$avp(mos_average)",0) .. "\n ")
```

## RTPEngine output

```bash

[1590498099.927466] INFO: [103103NTUyYmUxMDU0ODRkNDUzNGVhNDUzZWFlZjEyMmU1ZjY]: Received command 'delete' from 192.168.1.108:58271
[1590498099.927500] DEBUG: [103103NTUyYmUxMDU0ODRkNDUzNGVhNDUzZWFlZjEyMmU1ZjY]: Dump for 'delete' from 192.168.1.108:58271: { "supports": [ "load limit" ], "call-id": "103103NTUyYmUxMDU0ODRkNDUzNGVhNDUzZWFlZjEyMmU1ZjY", "received-from": [ "IP4", "192.168.1.108" ], "from-tag": "bea85f0b", "command": "delete" }
[1590498099.927657] INFO: [103103NTUyYmUxMDU0ODRkNDUzNGVhNDUzZWFlZjEyMmU1ZjY]: Scheduling deletion of call branch 'bea85f0b' (via-branch '') in 30 seconds
[1590498099.927700] INFO: [103103NTUyYmUxMDU0ODRkNDUzNGVhNDUzZWFlZjEyMmU1ZjY]: Replying to 'delete' from 192.168.1.108:58271 (elapsed time 0.000158 sec)
[1590498099.927911] DEBUG: [103103NTUyYmUxMDU0ODRkNDUzNGVhNDUzZWFlZjEyMmU1ZjY]: Response dump for 'delete' to 192.168.1.108:58271: 

{
  "created": 1590498074,
  "created_us": 755783,
  "last signal": 1590498074,
  "SSRC": {
    "1451888189": {
      "average MOS": {
        "MOS": 43,
        "round-trip time": 13430,
        "jitter": 0,
        "packet loss": 0,
        "samples": 4
      },
      "lowest MOS": {
        "MOS": 43,
        "round-trip time": 24184,
        "jitter": 0,
        "packet loss": 0,
        "reported at": 1590498085
      },
      "highest MOS": {
        "MOS": 44,
        "round-trip time": 8218,
        "jitter": 0,
        "packet loss": 0,
        "reported at": 1590498089
      },
      "MOS progression": {
        "interval": 1,
        "entries": [
          {
            "MOS": 43,
            "round-trip time": 24184,
            "jitter": 0,
            "packet loss": 0,
            "reported at": 1590498085
          },
          {
            "MOS": 44,
            "round-trip time": 8218,
            "jitter": 0,
            "packet loss": 0,
            "reported at": 1590498089
          },
          {
            "MOS": 44,
            "round-trip time": 8846,
            "jitter": 0,
            "packet loss": 0,
            "reported at": 1590498096
          },
          {
            "MOS": 43,
            "round-trip time": 12473,
            "jitter": 0,
            "packet loss": 0,
            "reported at": 1590498099
          }
        ]
      }
    },
    "4006960018": {
      "average MOS": {
        "MOS": 43,
        "round-trip time": 8718,
        "jitter": 0,
        "packet loss": 0,
        "samples": 11
      },
      "lowest MOS": {
        "MOS": 43,
        "round-trip time": 20241,
        "jitter": 0,
        "packet loss": 0,
        "reported at": 1590498082
      },
      "highest MOS": {
        "MOS": 44,
        "round-trip time": 7084,
        "jitter": 0,
        "packet loss": 0,
        "reported at": 1590498090
      },
      "MOS progression": {
        "interval": 1,
        "entries": [
          {
            "MOS": 43,
            "round-trip time": 20241,
            "jitter": 0,
            "packet loss": 0,
            "reported at": 1590498082
          },
          {
            "MOS": 43,
            "round-trip time": 9101,
            "jitter": 3,
            "packet loss": 0,
            "reported at": 1590498086
          },
          {
            "MOS": 44,
            "round-trip time": 7084,
            "jitter": 0,
            "packet loss": 0,
            "reported at": 1590498090
          },
          {
            "MOS": 44,
            "round-trip time": 7061,
            "jitter": 0,
            "packet loss": 0,
            "reported at": 1590498091
          },
          {
            "MOS": 44,
            "round-trip time": 7058,
            "jitter": 0,
            "packet loss": 0,
            "reported at": 1590498092
          },
          {
            "MOS": 44,
            "round-trip time": 7065,
            "jitter": 0,
            "packet loss": 0,
            "reported at": 1590498093
          },
          {
            "MOS": 44,
            "round-trip time": 7069,
            "jitter": 0,
            "packet loss": 0,
            "reported at": 1590498094
          },
          {
            "MOS": 44,
            "round-trip time": 7062,
            "jitter": 0,
            "packet loss": 0,
            "reported at": 1590498095
          },
          {
            "MOS": 44,
            "round-trip time": 7986,
            "jitter": 0,
            "packet loss": 0,
            "reported at": 1590498096
          },
          {
            "MOS": 44,
            "round-trip time": 7997,
            "jitter": 0,
            "packet loss": 0,
            "reported at": 1590498097
          },
          {
            "MOS": 43,
            "round-trip time": 8175,
            "jitter": 0,
            "packet loss": 1,
            "reported at": 1590498099
          }
        ]
      }
    }
  },
  "tags": {
    "bea85f0b": {
      "tag": "bea85f0b",
      "label": "Aleg_label",
      "created": 1590498074,
      "in dialogue with": "cNgQQcg2N572N",
      "medias": [
        {
          "index": 1,
          "type": "audio",
          "protocol": "RTP/AVPF",
          "streams": [
            {
              "local port": 30280,
              "endpoint": {
                "family": "IPv4",
                "address": "192.168.1.108",
                "port": 59398
              },
              "advertised endpoint": {
                "family": "IPv4",
                "address": "192.168.1.108",
                "port": 59398
              },
              "last packet": 1590498099,
              "flags": [
                "RTP",
                "filled",
                "confirmed",
                "kernelized",
                "no kernel support"
              ],
              "SSRC": 1451888189,
              "stats": {
                "packets": 1228,
                "bytes": 209296,
                "errors": 12
              }
            },
            {
              "local port": 30281,
              "endpoint": {
                "family": "IPv4",
                "address": "192.168.1.108",
                "port": 59399
              },
              "advertised endpoint": {
                "family": "IPv4",
                "address": "192.168.1.108",
                "port": 59399
              },
              "last packet": 1590498099,
              "flags": [
                "RTCP",
                "filled",
                "confirmed",
                "kernelized",
                "no kernel support"
              ],
              "SSRC": 1451888189,
              "stats": {
                "packets": 7,
                "bytes": 544,
                "errors": 0
              }
            }
          ],
          "flags": [
            "initialized",
            "send",
            "recv"
          ]
        }
      ]
    },
    "cNgQQcg2N572N": {
      "tag": "cNgQQcg2N572N",
      "label": "Bleg_label",
      "created": 1590498074,
      "in dialogue with": "bea85f0b",
      "medias": [
        {
          "index": 1,
          "type": "audio",
          "protocol": "RTP/AVPF",
          "streams": [
            {
              "local port": 30260,
              "endpoint": {
                "family": "IPv4",
                "address": "192.168.1.109",
                "port": 30106
              },
              "advertised endpoint": {
                "family": "IPv4",
                "address": "192.168.1.109",
                "port": 30106
              },
              "last packet": 1590498099,
              "flags": [
                "RTP",
                "filled",
                "confirmed",
                "kernelized",
                "no kernel support",
                "ICE"
              ],
              "SSRC": 4006960018,
              "stats": {
                "packets": 950,
                "bytes": 163400,
                "errors": 0
              }
            },
            {
              "local port": 30261,
              "endpoint": {
                "family": "IPv4",
                "address": "192.168.1.109",
                "port": 30107
              },
              "advertised endpoint": {
                "family": "IPv4",
                "address": "192.168.1.109",
                "port": 30107
              },
              "last packet": 1590498099,
              "flags": [
                "RTCP",
                "filled",
                "confirmed",
                "kernelized",
                "no kernel support",
                "ICE"
              ],
              "SSRC": 4006960018,
              "stats": {
                "packets": 12,
                "bytes": 1324,
                "errors": 0
              }
            }
          ],
          "flags": [
            "initialized",
            "send",
            "recv",
            "ICE",
            "ICE controlling",
            "loop check"
          ]
        }
      ]
    }
  },
  "totals": {
    "RTP": {
      "packets": 2178,
      "bytes": 372696,
      "errors": 12
    },
    "RTCP": {
      "packets": 19,
      "bytes": 1868,
      "errors": 0
    }
  },
  "result": "ok"
}


[1590498125.890289] DEBUG: [103103NTUyYmUxMDU0ODRkNDUzNGVhNDUzZWFlZjEyMmU1ZjY/cNgQQcg2N572N/1]: Setting ICE candidate pair DcOfY2YBtwHMVTEW:9900868460:2 as failed
[1590498126.000085] DEBUG: timer run time = 0.000014 sec
[1590498128.000126] DEBUG: timer run time = 0.000011 sec
[1590498130.000087] INFO: [103103NTUyYmUxMDU0ODRkNDUzNGVhNDUzZWFlZjEyMmU1ZjY]: Call branch 'bea85f0b' (label 'Aleg_label', via-branch '') deleted, no more branches remaining
[1590498130.000111] INFO: [103103NTUyYmUxMDU0ODRkNDUzNGVhNDUzZWFlZjEyMmU1ZjY]: Final packet stats:
[1590498130.000131] INFO: [103103NTUyYmUxMDU0ODRkNDUzNGVhNDUzZWFlZjEyMmU1ZjY]: --- Tag 'bea85f0b' (label 'Aleg_label'), created 0:56 ago for branch '', in dialogue with 'cNgQQcg2N572N'
[1590498130.000146] INFO: [103103NTUyYmUxMDU0ODRkNDUzNGVhNDUzZWFlZjEyMmU1ZjY]: ------ Media #1 (audio over RTP/AVPF) using PCMA/8000
[1590498130.000161] INFO: [103103NTUyYmUxMDU0ODRkNDUzNGVhNDUzZWFlZjEyMmU1ZjY]: --------- Port   192.168.1.109:30280 <>   192.168.1.108:59398, SSRC 568a0e3d, 1228 p, 209296 b, 12 e, 31 ts
[1590498130.000173] INFO: [103103NTUyYmUxMDU0ODRkNDUzNGVhNDUzZWFlZjEyMmU1ZjY]: --------- Port   192.168.1.109:30281 <>   192.168.1.108:59399 (RTCP), SSRC 568a0e3d, 7 p, 544 b, 0 e, 31 ts
[1590498130.000183] INFO: [103103NTUyYmUxMDU0ODRkNDUzNGVhNDUzZWFlZjEyMmU1ZjY]: --- Tag 'cNgQQcg2N572N' (label 'Bleg_label'), created 0:56 ago for branch '', in dialogue with 'bea85f0b'
[1590498130.000194] INFO: [103103NTUyYmUxMDU0ODRkNDUzNGVhNDUzZWFlZjEyMmU1ZjY]: ------ Media #1 (audio over RTP/AVPF) using PCMA/8000
[1590498130.000207] INFO: [103103NTUyYmUxMDU0ODRkNDUzNGVhNDUzZWFlZjEyMmU1ZjY]: --------- Port   192.168.1.109:30260 <>   192.168.1.109:30106, SSRC eed55b92, 950 p, 163400 b, 0 e, 31 ts
[1590498130.000218] INFO: [103103NTUyYmUxMDU0ODRkNDUzNGVhNDUzZWFlZjEyMmU1ZjY]: --------- Port   192.168.1.109:30261 <>   192.168.1.109:30107 (RTCP), SSRC eed55b92, 12 p, 1324 b, 0 e, 31 ts
[1590498130.000227] INFO: [103103NTUyYmUxMDU0ODRkNDUzNGVhNDUzZWFlZjEyMmU1ZjY]: --- SSRC eed55b92
[1590498130.000237] INFO: [103103NTUyYmUxMDU0ODRkNDUzNGVhNDUzZWFlZjEyMmU1ZjY]: ------ Average MOS 4.3, lowest MOS 4.3 (at 0:08), highest MOS 4.4 (at 0:16)
[1590498130.000246] INFO: [103103NTUyYmUxMDU0ODRkNDUzNGVhNDUzZWFlZjEyMmU1ZjY]: --- SSRC 568a0e3d
[1590498130.000277] INFO: [103103NTUyYmUxMDU0ODRkNDUzNGVhNDUzZWFlZjEyMmU1ZjY]: ------ Average MOS 4.3, lowest MOS 4.3 (at 0:10), highest MOS 4.4 (at 0:14)



```

**Ref** :

KEMI - https://kamailio.org/docs/tutorials/devel/kamailio-kemi-framework
RTPEngine module - https://kamailio.org/docs/modules/devel/modules/rtpengine.htm
Dispatcher module - https://www.kamailio.org/docs/modules/5.1.x/modules/dispatcher.html#dispatcher.f.ds_select_domain