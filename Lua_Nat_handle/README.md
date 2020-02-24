# Kamailio Lua Call routing Script to Handle NAT

Run with kamailio cfg 
```bash
kamailio -f kamailio_nathandle.cfg -Ee
```

To see existing running instances of kamailio 
```bash
ps -ef | grep kamailio 
```

Killing existing instance of kamailio 
```bash
pkill kamailio
```

To read more about Lua scripts for call routing on kamailip sip server 
https://telecom.altanai.com/2018/05/08/lua-scripts-for-kamailio-routing/

## KSR function used :

KSR.x.exit() to trigger the stop of executing the script
KSR.drop() is only marking the SIP message for drop, but doesn't stop the execution of the script

