# jsonrpcs for Remote process calls using kamctl in kamailio 

## UL commands

### get online users 
once regsieterd the users can also be diapled using kamctl coamands 
```
> kamctl online 
altanai
bisht
```

## dialog commands 
get call state using kamcmd dlg.list command 
```
>kamcmd dlg.list
{
	h_entry: 486
	h_id: 8019
	call-id: 97576YmZlZDUzZTBiZWViOGFhMjNlMTExZGYyM2I3N2Y3MWU
	from_uri: sip:kate@ip_addr
	to_uri: sip:altanai@ip_addr
	state: 5
	start_ts: 1563268239
	init_ts: 1563268227
	timeout: 0
	lifetime: 43200
	dflags: 516
	sflags: 0
	iflags: 0
	caller: {
		tag: 838e7651
		contact: sip:kate@ua_addr:25797;rinstance=4343a1eb7a321c75;alias=ua_addr~25797~1
		cseq: 1
		route_set: 
		socket: udp:10.130.74.151:5060
	}
	callee: {
		tag: 42aeae5e
		contact: sip:altanai@ua_addr:35570;alias=ua_addr~35570~1
		cseq: 0
		route_set: 
		socket: udp:10.130.74.151:5060
	}
	profiles: {
	}
	variables: {
	}
}
```

Ref : https://kamailio.org/docs/modules/5.1.x/modules/jsonrpcs.html