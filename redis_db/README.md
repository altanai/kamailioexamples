## Redis Cacahe for quick storage and retrival 

db_redis module - provides DB APIv1 connector for the Redis server 

must be installed before running Kamailio with this module loaded:
hiredis - available at https://github.com/redis/hiredis


## building Kamailio version 5.2 with db_redis module

dependencies 
```
apt install libjansson-dev 
apt-get install libevent-de
```
to generate a modules.lst file 
```
make cfg 
```
if u use the default modules.lst , it will not build some modules which are by default inside exclude block. This also include ndb_redis. Hence either add it seprately to include_modules setion in modules.lst or use the following command while make 
```
make include_modules=db_redis
```
alternatively the module redis can be build after kamailio installtion too such as 
```
> cd src/modules/db_redis/
> make && make install
```
check installed kamailio version 
```
version: kamailio 5.2.3 (x86_64/linux) c23ea8
flags: STATS: Off, USE_TCP, USE_TLS, USE_SCTP, TLS_HOOKS, USE_RAW_SOCKS, DISABLE_NAGLE, USE_MCAST, DNS_IP_HACK, SHM_MEM, SHM_MMAP, PKG_MALLOC, Q_MALLOC, F_MALLOC, TLSF_MALLOC, DBG_SR_MEMORY, USE_FUTEX, FAST_LOCK-ADAPTIVE_WAIT, USE_DNS_CACHE, USE_DNS_FAILOVER, USE_NAPTR, USE_DST_BLACKLIST, HAVE_RESOLV_RES
ADAPTIVE_WAIT_LOOPS=1024, MAX_RECV_BUFFER_SIZE 262144 MAX_URI_SIZE 1024, BUF_SIZE 65535, DEFAULT PKG_SIZE 8MB
poll method support: poll, epoll_lt, epoll_et, sigio_rt, select.
id: c23ea8 
compiled on 09:06:42 Jul 17 2019 with gcc 5.4.0
```

## Redis storage and retrival 

redis using HMSET which sets the specified fields to their respective values in the hash stored at key. 
Such as after redis-cli screen do 
```
> HMSET myhash field1 "Hello" field2 "World"
```
will use hash "myhash" to store 2 key value pairs whose value can be ontained as 
```
>HGET myhash field1
"Hello"
```

get all keys by 
```
keys *
```

remoev all keys by 
```
flushall
```

monitor realtime redis operations by 
```
>redis-cli monitor 
``` 

## Debug Helper 

**Issue 1**  : ERROR: db_redis [redis_table.c:685]: db_redis_parse_schema(): Failed to open schema directory '/usr/share/kamailio/db_redis/kamailio'
**Solution** : Redis has differnt schemas for diff module. We have to create a schema defination for each . For exmaple for usrloc module, create file location in sceham_path , and add comma-separated list of column definitions in the format
<column-name>/<type>[,<column-name>/<type> ...] 
```
cd /etc/kamailio/db_redis/kamailio
vi location
```
location table schema is ( https://kamailio.org/docs/db-tables/kamailio-db-5.2.x.html#gen-db-location)

name		type		size	default	null	key	extra attributes	description
id			unsigned int	10			no	primary	autoincrement	unique ID
ruid		string			64	''		no			Record internal unique id
username	string			64	''		no			Username / phone number
domain		string			64	NULL	yes			Domain name
contact		string			512	''		no			Contact header field value provides a URI whose meaning depends on the type of request or response it is in.
received	string			128	NULL	yes			Received IP:PORT in the format SIP:IP:PORT
path		string			512	NULL	yes			Path Header(s) per RFC 3327
expires		datetime	not specified	'2030-05-28 21:32:15'	no			Date and time when this entry expires.
q			float			10,2	1.0	no			Value used for preferential routing.
callid		string			255	'Default-Call-ID'	no			Call-ID header field uniquely identifies a particular invitation or all registrations of a particular client.
cseq		int				11	1		no			CSeq header field contains a single decimal sequence number and the request method.
last_modified	datetime	not specified	'2000-01-01 00:00:01'	no			Date and time when this entry was last modified.
flags		int				11	0		no			Internal flags
cflags		int				11	0		no			Branch and contact flags
user_agent	string			255	''		no			User-Agent header field contains information about the UAC originating the request.
socket		string			64	NULL	yes			Socket used to connect to Kamailio. For example: UDP:IP:PORT
methods		int				11	NULL	yes			Flags that indicate the SIP Methods this contact will accept.
instance	string			255	NULL	yes			The value of SIP instance parameter for GRUU.
reg_id		int				11	0		no			The value of reg-id contact parameter
server_id	int				11	0		no			The value of server_id from configuration file
connection_id	int			11	0		no			The value of connection id for location record
keepalive	int				11	0		no			The value to control sending keep alive requests
partition	int				11	0		no			The value to of the partition for keep alive requests

that trsalted to following redis DB schema, which needs to be inserted seprately in scehma file. Redis will use this to HMSET
```
username/string,domain/string,contact/string,received/string,path/string,expires/timestamp,q/double,callid/string,cseq/int,last_modified/timestamp,flags/int,cflags/int,user_agent/string,socket/string,methods/int,ruid/string,reg_id/int,instance/string,server_id/int,connection_id/int,keepalive/int,partition/int
```
save and give path 
```
modparam("db_redis", "schema_path", "/etc/kamailio/db_redis/kamailio")
```			

**Issue 2** :  db_redis_parse_keys(): No table schema found for table 'version', fix config by adding one to the 'schema' mod-param!
**Solution** : The above schema defination table is followd by a line holding the table version.
semi-colon separated list of definitions in the format <table-name>=<entry>:<column-name>[&<map-name>:<column-name>,<column-name>...]
Each table must at least have an "entry" key for db_redis to be able to store data.

**Issue 3** : ERROR: db_redis [redis_table.c:542]: db_redis_parse_keys(): No table schema found for table 'version', fix config by adding one to the 'schema' mod-param!
 0(21179) ERROR: db_redis [redis_connection.c:218]: db_redis_new_connection(): failed to parse 'keys' module parameter
 0(21179) ERROR: <core> [db.c:319]: db_do_init2(): could not add connection to the pool 0(21179) ERROR: usrloc [dlist.c:646]: register_udomain(): failed to open database connection
 0(21179) ERROR: registrar [registrar.c:683]: domain_fixup(): failed to register domain
 0(21179) ERROR: <core> [core/route.c:1153]: fix_actions(): fixing failed (code=-1) at cfg:/etc/kamailio/kamailio_redis.cfg:613
 0(21179) ERROR: <core> [core/rvalue.c:3859]: fix_rval_expr(): failure in cfg at line: 613 col: 22
 0(21179) ERROR: <core> [core/rvalue.c:3859]: fix_rval_expr(): failure in cfg at line: 613 col: 22
 0(21179) ERROR: <core> [core/route.c:1153]: fix_actions(): fixing failed (code=-1) at cfg:/etc/kamailio/kamailio_redis.cfg:616
**Solution**  For every kind of module there will be speific version , which needs to be included after schema defination , such as doe dialog module it is 7 so schema file will be 
```
id/int,hash_entry/int,hash_id/int,callid/string,from_uri/string,from_tag/string,to_uri/string,to_tag/string,caller_cseq/string,callee_cseq/string,caller_route_set/string,callee_route_set/string,caller_contact/string,callee_contact/string,caller_sock/string,callee_sock/string,state/int,start_time/int,timeout/int,sflags/int,iflags/int,toroute_name/string,req_uri/string,xdata/string,
7
```
a list of module versions is 
```
table_name(string) table_version(int) 
version:1
acc:5
acc_cdrs:2
active_watchers:12
address:6
aliases:8
carrier_name:1
carrierfailureroute:2
carrierroute:3
cpl:1
dbaliases:1
dialog:7
dialog_vars:1
dialplan:2
dispatcher:4
domain:2
domain_attrs:1
domain_name:1
domainpolicy:2
dr_gateways:3
dr_groups:2
dr_gw_lists:1
dr_rules:3
globalblacklist:1
grp:2
htable:2
imc_members:1
imc_rooms:1
lcr_gw:3
lcr_rule:3
lcr_rule_target:1
location:9
location_attrs:1
matrix:1
missed_calls:4
mohqcalls:1
mohqueues:1
mtree:1
mtrees:2
pdt:1
pl_pipes:1
presentity:5
pua:7
purplemap:1
re_grp:1
rls_presentity:1
rls_watchers:3
rtpengine:1
rtpproxy:1
sca_subscriptions:2
silo:8
sip_trace:4
speed_dial:2
subscriber:7
topos_d:1
topos_t:1
trusted:6
uacreg:3
uid_credentials:7
uid_domain:2
uid_domain_attrs:1
uid_global_attrs:1
uid_uri:3
uid_uri_attrs:2
uid_user_attrs:3
uri:1
userblacklist:1
usr_preferences:2
watchers:3
xcap:4
```
**Issue 4** :  1(3205) ERROR: db_redis [redis_dbase.c:405]: db_redis_build_entry_keys(): Failed to create direct entry key, no matching key definition
 1(3205) ERROR: db_redis [redis_dbase.c:1892]: db_redis_insert(): failed to build entry keys
 1(3205) ERROR: db_redis [redis_dbase.c:1976]: db_redis_insert(): failed to do the insert
 1(3205) ERROR: dialog [dlg_db_handler.c:905]: update_dialog_dbinfo_unsafe(): could not add another dialog to db
**Solution** : if it complains on the structure of keys , check the keys defination in kamailio.cfg where dilaog module's params are defined .
Some common keys definations are :
userloc keys 
```
modparam("db_redis", "keys", "location=entry:ruid&usrdom:username,domain&timer:partition,keepalive")
```
acc keys 
```
modparam("db_redis", "keys", "acc=entry:callid,time_hires&cid:callid")
```
subscriber keys
```
modparam("db_redis", "keys", "subscriber=entry:username,domain")
```
dialog keys 
```
modparam("db_redis", "keys", "dialog=entry:hash_entry,hash_id,callid")
modparam("db_redis", "keys", "dialog_vars=entry:hash_entry,hash_id,dialog_key,dialog_value")
```


*Ref* :
Redis Server - https://www.redis.io
DB redis module - https://kamailio.org/docs/modules/5.2.x/modules/db_redis.html
db_redis schemas - https://github.com/kamailio/kamailio/tree/master/utils/kamctl/db_redis/kamailio

