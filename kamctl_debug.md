# kamctl debug

## kamctl commands

Existing commands:

 -- command 'start|stop|restart|trap'

 trap ............................... trap with gdb Kamailio processes
 restart ............................ restart Kamailio
 start .............................. start Kamailio
 stop ............................... stop Kamailio

 -- command 'acl' - manage access control lists (acl)

 acl show [<username>] .............. show user membership
 acl grant <username> <group> ....... grant user membership (*)
 acl revoke <username> [<group>] .... grant user membership(s) (*)

 -- command 'lcr' - manage least cost routes (lcr)

 lcr show_gws....... show database gateways
 lcr show_routes.... show database routes
 lcr dump_gws....... show in memory gateways
 lcr dump_routes.... show in memory routes
 lcr reload ........ reload lcr gateways and routes
 lcr eval_weights .. evaluates probability for given GW's weights

 -- command 'cr' - manage carrierroute tables

 cr show ....................................................... show tables
 cr reload ..................................................... reload tables
 cr dump ....................................................... show in memory tables
 cr addcn <carrier id> <carrier name> .......................... add a carrier name
 cr rmcn  <carrier id> ......................................... rm a carrier name
 cr adddn <domain id> <domain name> ............................ add a domain name
 cr rmdn  <domain id> .......................................... rm a domain name
 cr addcarrier <carrier> <scan_prefix> <domain> <rewrite_host> ................
               <prob> <strip> <rewrite_prefix> <rewrite_suffix> ...............
               <flags> <mask> <comment> .........................add a carrier
               (prob, strip, rewrite_prefix, rewrite_suffix,...................
                flags, mask and comment are optional arguments) ...............
 cr rmcarrier  <carrier> <scan_prefix> <domain> ................ rm a carrier

 -- command 'rpid' - manage Remote-Party-ID (RPID)

 rpid add <username> <rpid> ......... add rpid for a user (*)
 rpid rm <username> ................. set rpid to NULL for a user (*)
 rpid show <username> ............... show rpid of a user

 -- command 'add|passwd|rm' - manage subscribers

 add <username> <password> .......... add a new subscriber (*)
 show <username> .................... show subscriber attributes (*)
 passwd <username> <passwd> ......... change user's password (*)
 rm <username> ...................... delete a user (*)
 sets <username> <attr> <val> ....... set string attribute (column value)
 setn <username> <attr> <val> ....... set numeric attribute (column value)

 -- command 'add|dump|reload|rm|show' - manage trusted

 trusted show ...................... show db content
 trusted dump ...................... show cache content
 trusted reload .................... reload db table into cache
 trusted add <src_ip> <proto> <from_pattern> <tag>
             ....................... add a new entry
	     ....................... (from_pattern and tag are optional arguments)
 trusted rm <src_ip> ............... remove all entries for the given src_ip

 -- command 'add|dump|reload|rm|show' - manage address

 address show ...................... show db content
 address dump ...................... show cache content
 address reload .................... reload db table into cache
 address add <grp> <ipaddr> <mask> <port> <tag>
             ....................... add a new entry
	     ....................... (mask, port and tag are optional arguments)
 address rm <grp> <ipaddr> ......... remove entries for given grp and ipaddr

 -- command 'dispatcher' - manage dispatcher

   * Examples: dispatcher add 1 sip:1.2.3.1:5050 1 5 'prefix=123' 'gw one'
   *           dispatcher add 2 sip:1.2.3.4:5050 3 0
   *           dispatcher rm 4
 dispatcher show ..................... show dispatcher gateways
 dispatcher reload ................... reload dispatcher gateways
 dispatcher dump ..................... show in memory dispatcher gateways
 dispatcher add <setid> <destination> [flags] [priority] [attrs] [description]
            .......................... add gateway
 dispatcher rm <id> .................. delete gateway

 -- command 'dialog' - manage dialog records

   * Examples: dialog show
   *           dialog showdb
 dialog show ..................... show in-memory dialog records
 dialog showdb ................... show database dialog records

 -- command 'srv' - server management commands

   * Examples: srv sockets
   *           srv rpclist
 srv sockets ................... show the list of listen sockets
 srv aliases ................... show the list of server aliases
 srv rpclist ................... show the list of server rpc commands

 -- command 'add|dump|reload|rm|show' - manage mtree

 mtree show <tname> .................. show db content
 mtree dump [<tname>] ................ show cache content
 mtree reload [<tname>] .............. reload db table into cache
 mtree add <tname> <tprefix> <tvalue>
             ......................... add a new entry
 mtree rm <tname> <tprefix> .......... remove entries for given tname and tprefix

 -- command 'db' - database operations

 db exec <query> ..................... execute SQL query
 db roexec <roquery> ................. execute read-only SQL query
 db run <id> ......................... execute SQL query from $id variable
 db rorun <id> ....................... execute read-only SQL query from 
                                       $id variable
 db show <table> ..................... display table content
 db showg <table> .................... display formatted table content
 db smatch <table> <key> <value>...... display record from table that has
           ........................... column key equal to value as string
 db nmatch <table> <key> <value>...... display record from table that has
           ........................... column key equal to value as non-string
 db connect .......................... connect to db server via cli
 db version add <table> <value> ...... add new value in version table
 db version set <table> <value> ...... set value in version table
 db version update <table> <value> ... update value in version table

 -- command 'speeddial' - manage speed dials (short numbers)

 speeddial show <speeddial-id> ....... show speeddial details
 speeddial list <sip-id> ............. list speeddial for uri
 speeddial add <sip-id> <sd-id> <new-uri> [<desc>] ...
           ........................... add a speedial (*)
 speeddial rm <sip-id> <sd-id> ....... remove a speeddial (*)
 speeddial help ...................... help message
    - <speeddial-id>, <sd-id> must be an AoR (username@domain)
    - <sip-id> must be an AoR (username@domain)
    - <new-uri> must be a SIP AoR (sip:username@domain)
    - <desc> a description for speeddial

 -- command 'avp' - manage AVPs

 avp list [-T table] [-u <sip-id|uuid>]
     [-a attribute] [-v value] [-t type] ... list AVPs
 avp add [-T table] <sip-id|uuid>
     <attribute> <type> <value> ............ add AVP (*)
 avp rm [-T table]  [-u <sip-id|uuid>]
     [-a attribute] [-v value] [-t type] ... remove AVP (*)
 avp help .................................. help message
    - -T - table name
    - -u - SIP id or unique id
    - -a - AVP name
    - -v - AVP value
    - -t - AVP name and type (0 (str:str), 1 (str:int),
                              2 (int:str), 3 (int:int))
    - <sip-id> must be an AoR (username@domain)
    - <uuid> must be a string but not AoR

 -- command 'alias_db' - manage database aliases

 alias_db show <alias> .............. show alias details
 alias_db list <sip-id> ............. list aliases for uri
 alias_db add <alias> <sip-id> ...... add an alias (*)
 alias_db rm <alias> ................ remove an alias (*)
 alias_db help ...................... help message
    - <alias> must be an AoR (username@domain)"
    - <sip-id> must be an AoR (username@domain)"

 -- command 'domain' - manage local domains

 domain reload ....................... reload domains from disk
 domain show ......................... show current domains in memory
 domain showdb ....................... show domains in the database
 domain add <domain> ................. add the domain to the database
 domain rm <domain> .................. delete the domain from the database

 -- command 'uid_domain' - manage local domains

 uid_domain reload ....................... reload domains from disk
 uid_domain show ......................... show current domains in memory
 uid_domain showdb ....................... show domains in the database
 uid_domain add <domain> [did] [flags].... add the domain to the database
 uid_domain rm <domain> .................. delete the domain from the database

 -- command 'cisco_restart' - restart CISCO phone (NOTIFY)

 cisco_restart <uri> ................ restart phone configured for <uri>

 -- command 'online' - dump online users from memory

 online ............................. display online users

 -- command 'monitor' - show internal status

 monitor ............................ show server's internal status

 -- command 'ping' - ping a SIP URI (OPTIONS)

 ping <uri> ......................... ping <uri> with SIP OPTIONS

 -- command 'ul|alias' - manage user location or aliases

 ul show [<username>]................... show in-RAM online users
 ul show --brief........................ show in-RAM online users in short format
 ul rm <username> [<contact URI>]....... delete user's usrloc entries
 ul add <username> <uri> ............... introduce a permanent usrloc entry
 ul add <username> <uri> <expires> ..... introduce a temporary usrloc entry
 ul add <user> <uri> <expires> <path> .. introduce a temporary usrloc entry

 -- command 'ps' - print details about running processes

 ps ................................. details about running processes

 -- command 'uptime' - print uptime details

 uptime ............................. print start time end elapsed seconds

 -- command 'stats' - print internal statistics

 stats [group]....................... dump all or a group of internall statistics

 -- command 'rpc' - send raw RPC commands

 rpc ................................ send raw RPC command

 -- command 'kamcmd'

 kamcmd ............................. send command through kamcmd

root@ip-10-130-74-151:/home/ubuntu# kamctl tls.info
/usr/local/sbin/kamctl 5.2.0

Existing commands:

 -- command 'start|stop|restart|trap'

 trap ............................... trap with gdb Kamailio processes
 restart ............................ restart Kamailio
 start .............................. start Kamailio
 stop ............................... stop Kamailio

 -- command 'acl' - manage access control lists (acl)

 acl show [<username>] .............. show user membership
 acl grant <username> <group> ....... grant user membership (*)
 acl revoke <username> [<group>] .... grant user membership(s) (*)

 -- command 'lcr' - manage least cost routes (lcr)

 lcr show_gws....... show database gateways
 lcr show_routes.... show database routes
 lcr dump_gws....... show in memory gateways
 lcr dump_routes.... show in memory routes
 lcr reload ........ reload lcr gateways and routes
 lcr eval_weights .. evaluates probability for given GW's weights

 -- command 'cr' - manage carrierroute tables

 cr show ....................................................... show tables
 cr reload ..................................................... reload tables
 cr dump ....................................................... show in memory tables
 cr addcn <carrier id> <carrier name> .......................... add a carrier name
 cr rmcn  <carrier id> ......................................... rm a carrier name
 cr adddn <domain id> <domain name> ............................ add a domain name
 cr rmdn  <domain id> .......................................... rm a domain name
 cr addcarrier <carrier> <scan_prefix> <domain> <rewrite_host> ................
               <prob> <strip> <rewrite_prefix> <rewrite_suffix> ...............
               <flags> <mask> <comment> .........................add a carrier
               (prob, strip, rewrite_prefix, rewrite_suffix,...................
                flags, mask and comment are optional arguments) ...............
 cr rmcarrier  <carrier> <scan_prefix> <domain> ................ rm a carrier

 -- command 'rpid' - manage Remote-Party-ID (RPID)

 rpid add <username> <rpid> ......... add rpid for a user (*)
 rpid rm <username> ................. set rpid to NULL for a user (*)
 rpid show <username> ............... show rpid of a user

 -- command 'add|passwd|rm' - manage subscribers

 add <username> <password> .......... add a new subscriber (*)
 show <username> .................... show subscriber attributes (*)
 passwd <username> <passwd> ......... change user's password (*)
 rm <username> ...................... delete a user (*)
 sets <username> <attr> <val> ....... set string attribute (column value)
 setn <username> <attr> <val> ....... set numeric attribute (column value)

 -- command 'add|dump|reload|rm|show' - manage trusted

 trusted show ...................... show db content
 trusted dump ...................... show cache content
 trusted reload .................... reload db table into cache
 trusted add <src_ip> <proto> <from_pattern> <tag>
             ....................... add a new entry
	     ....................... (from_pattern and tag are optional arguments)
 trusted rm <src_ip> ............... remove all entries for the given src_ip

 -- command 'add|dump|reload|rm|show' - manage address

 address show ...................... show db content
 address dump ...................... show cache content
 address reload .................... reload db table into cache
 address add <grp> <ipaddr> <mask> <port> <tag>
             ....................... add a new entry
	     ....................... (mask, port and tag are optional arguments)
 address rm <grp> <ipaddr> ......... remove entries for given grp and ipaddr

 -- command 'dispatcher' - manage dispatcher

   * Examples: dispatcher add 1 sip:1.2.3.1:5050 1 5 'prefix=123' 'gw one'
   *           dispatcher add 2 sip:1.2.3.4:5050 3 0
   *           dispatcher rm 4
 dispatcher show ..................... show dispatcher gateways
 dispatcher reload ................... reload dispatcher gateways
 dispatcher dump ..................... show in memory dispatcher gateways
 dispatcher add <setid> <destination> [flags] [priority] [attrs] [description]
            .......................... add gateway
 dispatcher rm <id> .................. delete gateway

 -- command 'dialog' - manage dialog records

   * Examples: dialog show
   *           dialog showdb
 dialog show ..................... show in-memory dialog records
 dialog showdb ................... show database dialog records

 -- command 'srv' - server management commands

   * Examples: srv sockets
   *           srv rpclist
 srv sockets ................... show the list of listen sockets
 srv aliases ................... show the list of server aliases
 srv rpclist ................... show the list of server rpc commands

 -- command 'add|dump|reload|rm|show' - manage mtree

 mtree show <tname> .................. show db content
 mtree dump [<tname>] ................ show cache content
 mtree reload [<tname>] .............. reload db table into cache
 mtree add <tname> <tprefix> <tvalue>
             ......................... add a new entry
 mtree rm <tname> <tprefix> .......... remove entries for given tname and tprefix

 -- command 'db' - database operations

 db exec <query> ..................... execute SQL query
 db roexec <roquery> ................. execute read-only SQL query
 db run <id> ......................... execute SQL query from $id variable
 db rorun <id> ....................... execute read-only SQL query from 
                                       $id variable
 db show <table> ..................... display table content
 db showg <table> .................... display formatted table content
 db smatch <table> <key> <value>...... display record from table that has
           ........................... column key equal to value as string
 db nmatch <table> <key> <value>...... display record from table that has
           ........................... column key equal to value as non-string
 db connect .......................... connect to db server via cli
 db version add <table> <value> ...... add new value in version table
 db version set <table> <value> ...... set value in version table
 db version update <table> <value> ... update value in version table

 -- command 'speeddial' - manage speed dials (short numbers)

 speeddial show <speeddial-id> ....... show speeddial details
 speeddial list <sip-id> ............. list speeddial for uri
 speeddial add <sip-id> <sd-id> <new-uri> [<desc>] ...
           ........................... add a speedial (*)
 speeddial rm <sip-id> <sd-id> ....... remove a speeddial (*)
 speeddial help ...................... help message
    - <speeddial-id>, <sd-id> must be an AoR (username@domain)
    - <sip-id> must be an AoR (username@domain)
    - <new-uri> must be a SIP AoR (sip:username@domain)
    - <desc> a description for speeddial

 -- command 'avp' - manage AVPs

 avp list [-T table] [-u <sip-id|uuid>]
     [-a attribute] [-v value] [-t type] ... list AVPs
 avp add [-T table] <sip-id|uuid>
     <attribute> <type> <value> ............ add AVP (*)
 avp rm [-T table]  [-u <sip-id|uuid>]
     [-a attribute] [-v value] [-t type] ... remove AVP (*)
 avp help .................................. help message
    - -T - table name
    - -u - SIP id or unique id
    - -a - AVP name
    - -v - AVP value
    - -t - AVP name and type (0 (str:str), 1 (str:int),
                              2 (int:str), 3 (int:int))
    - <sip-id> must be an AoR (username@domain)
    - <uuid> must be a string but not AoR

 -- command 'alias_db' - manage database aliases

 alias_db show <alias> .............. show alias details
 alias_db list <sip-id> ............. list aliases for uri
 alias_db add <alias> <sip-id> ...... add an alias (*)
 alias_db rm <alias> ................ remove an alias (*)
 alias_db help ...................... help message
    - <alias> must be an AoR (username@domain)"
    - <sip-id> must be an AoR (username@domain)"

 -- command 'domain' - manage local domains

 domain reload ....................... reload domains from disk
 domain show ......................... show current domains in memory
 domain showdb ....................... show domains in the database
 domain add <domain> ................. add the domain to the database
 domain rm <domain> .................. delete the domain from the database

 -- command 'uid_domain' - manage local domains

 uid_domain reload ....................... reload domains from disk
 uid_domain show ......................... show current domains in memory
 uid_domain showdb ....................... show domains in the database
 uid_domain add <domain> [did] [flags].... add the domain to the database
 uid_domain rm <domain> .................. delete the domain from the database

 -- command 'cisco_restart' - restart CISCO phone (NOTIFY)

 cisco_restart <uri> ................ restart phone configured for <uri>

 -- command 'online' - dump online users from memory

 online ............................. display online users

 -- command 'monitor' - show internal status

 monitor ............................ show server's internal status

 -- command 'ping' - ping a SIP URI (OPTIONS)

 ping <uri> ......................... ping <uri> with SIP OPTIONS

 -- command 'ul|alias' - manage user location or aliases

 ul show [<username>]................... show in-RAM online users
 ul show --brief........................ show in-RAM online users in short format
 ul rm <username> [<contact URI>]....... delete user's usrloc entries
 ul add <username> <uri> ............... introduce a permanent usrloc entry
 ul add <username> <uri> <expires> ..... introduce a temporary usrloc entry
 ul add <user> <uri> <expires> <path> .. introduce a temporary usrloc entry

 -- command 'ps' - print details about running processes

 ps ................................. details about running processes

 -- command 'uptime' - print uptime details

 uptime ............................. print start time end elapsed seconds

 -- command 'stats' - print internal statistics

 stats [group]....................... dump all or a group of internall statistics

 -- command 'rpc' - send raw RPC commands

 rpc ................................ send raw RPC command

 -- command 'kamcmd'

 kamcmd ............................. send command through kamcmd


```
>kamctl stats 

kamctl stats
{
  "jsonrpc":  "2.0",
  "result": [
    "core:bad_URIs_rcvd = 0",
    "core:bad_msg_hdr = 0",
    "core:drop_replies = 0",
    "core:drop_requests = 0",
    "core:err_replies = 0",
    "core:err_requests = 0",
    "core:fwd_replies = 0",
    "core:fwd_requests = 0",
    "core:rcv_replies = 0",
    "core:rcv_replies_18x = 0",
    "core:rcv_replies_1xx = 0",
    "core:rcv_replies_1xx_bye = 0",
    "core:rcv_replies_1xx_cancel = 0",
    "core:rcv_replies_1xx_invite = 0",
    "core:rcv_replies_1xx_message = 0",
    "core:rcv_replies_1xx_prack = 0",
    "core:rcv_replies_1xx_refer = 0",
    "core:rcv_replies_1xx_reg = 0",
    "core:rcv_replies_1xx_update = 0",
    "core:rcv_replies_2xx = 0",
    "core:rcv_replies_2xx_bye = 0",
    "core:rcv_replies_2xx_cancel = 0",
    "core:rcv_replies_2xx_invite = 0",
    "core:rcv_replies_2xx_message = 0",
    "core:rcv_replies_2xx_prack = 0",
    "core:rcv_replies_2xx_refer = 0",
    "core:rcv_replies_2xx_reg = 0",
    "core:rcv_replies_2xx_update = 0",
    "core:rcv_replies_3xx = 0",
    "core:rcv_replies_3xx_bye = 0",
    "core:rcv_replies_3xx_cancel = 0",
    "core:rcv_replies_3xx_invite = 0",
    "core:rcv_replies_3xx_message = 0",
    "core:rcv_replies_3xx_prack = 0",
    "core:rcv_replies_3xx_refer = 0",
    "core:rcv_replies_3xx_reg = 0",
    "core:rcv_replies_3xx_update = 0",
    "core:rcv_replies_401 = 0",
    "core:rcv_replies_404 = 0",
    "core:rcv_replies_407 = 0",
    "core:rcv_replies_480 = 0",
    "core:rcv_replies_486 = 0",
    "core:rcv_replies_4xx = 0",
    "core:rcv_replies_4xx_bye = 0",
    "core:rcv_replies_4xx_cancel = 0",
    "core:rcv_replies_4xx_invite = 0",
    "core:rcv_replies_4xx_message = 0",
    "core:rcv_replies_4xx_prack = 0",
    "core:rcv_replies_4xx_refer = 0",
    "core:rcv_replies_4xx_reg = 0",
    "core:rcv_replies_4xx_update = 0",
    "core:rcv_replies_5xx = 0",
    "core:rcv_replies_5xx_bye = 0",
    "core:rcv_replies_5xx_cancel = 0",
    "core:rcv_replies_5xx_invite = 0",
    "core:rcv_replies_5xx_message = 0",
    "core:rcv_replies_5xx_prack = 0",
    "core:rcv_replies_5xx_refer = 0",
    "core:rcv_replies_5xx_reg = 0",
    "core:rcv_replies_5xx_update = 0",
    "core:rcv_replies_6xx = 0",
    "core:rcv_replies_6xx_bye = 0",
    "core:rcv_replies_6xx_cancel = 0",
    "core:rcv_replies_6xx_invite = 0",
    "core:rcv_replies_6xx_message = 0",
    "core:rcv_replies_6xx_prack = 0",
    "core:rcv_replies_6xx_refer = 0",
    "core:rcv_replies_6xx_reg = 0",
    "core:rcv_replies_6xx_update = 0",
    "core:rcv_requests = 1",
    "core:rcv_requests_ack = 0",
    "core:rcv_requests_bye = 0",
    "core:rcv_requests_cancel = 0",
    "core:rcv_requests_info = 0",
    "core:rcv_requests_invite = 0",
    "core:rcv_requests_message = 0",
    "core:rcv_requests_notify = 0",
    "core:rcv_requests_options = 1",
    "core:rcv_requests_prack = 0",
    "core:rcv_requests_publish = 0",
    "core:rcv_requests_refer = 0",
    "core:rcv_requests_register = 0",
    "core:rcv_requests_subscribe = 0",
    "core:rcv_requests_update = 0",
    "core:unsupported_methods = 0",
    "dns:failed_dns_request = 0",
    "registrar:accepted_regs = 0",
    "registrar:default_expire = 3600",
    "registrar:default_expires_range = 0",
    "registrar:expires_range = 0",
    "registrar:max_contacts = 0",
    "registrar:max_expires = 3600",
    "registrar:rejected_regs = 0",
    "shmem:fragments = 1",
    "shmem:free_size = 64288576",
    "shmem:max_used_size = 2820288",
    "shmem:real_used_size = 2820288",
    "shmem:total_size = 67108864",
    "shmem:used_size = 2578584",
    "sl:1xx_replies = 0",
    "sl:200_replies = 0",
    "sl:202_replies = 0",
    "sl:2xx_replies = 0",
    "sl:300_replies = 0",
    "sl:301_replies = 0",
    "sl:302_replies = 0",
    "sl:3xx_replies = 0",
    "sl:400_replies = 0",
    "sl:401_replies = 0",
    "sl:403_replies = 0",
    "sl:404_replies = 0",
    "sl:407_replies = 0",
    "sl:408_replies = 0",
    "sl:483_replies = 0",
    "sl:4xx_replies = 0",
    "sl:500_replies = 0",
    "sl:5xx_replies = 0",
    "sl:6xx_replies = 0",
    "sl:failures = 0",
    "sl:received_ACKs = 0",
    "sl:sent_err_replies = 0",
    "sl:sent_replies = 0",
    "sl:xxx_replies = 0",
    "tcp:con_reset = 0",
    "tcp:con_timeout = 0",
    "tcp:connect_failed = 0",
    "tcp:connect_success = 0",
    "tcp:current_opened_connections = 0",
    "tcp:current_write_queue_size = 0",
    "tcp:established = 0",
    "tcp:local_reject = 0",
    "tcp:passive_open = 0",
    "tcp:send_timeout = 0",
    "tcp:sendq_full = 0",
    "tmx:2xx_transactions = 0",
    "tmx:3xx_transactions = 0",
    "tmx:4xx_transactions = 0",
    "tmx:5xx_transactions = 0",
    "tmx:6xx_transactions = 0",
    "tmx:UAC_transactions = 0",
    "tmx:UAS_transactions = 0",
    "tmx:active_transactions = 0",
    "tmx:inuse_transactions = 0",
    "tmx:rpl_absorbed = 0",
    "tmx:rpl_generated = 0",
    "tmx:rpl_received = 0",
    "tmx:rpl_relayed = 0",
    "tmx:rpl_sent = 0",
    "usrloc:location-contacts = 0",
    "usrloc:location-expires = 0",
    "usrloc:location-users = 0",
    "usrloc:registered_users = 0"
  ],
  "id": 2479
}

```

## debugging 

**Issue1** : kamilio_ctl no such file for commands csuch as kamcmd dispatcher.ping_active 0
ERROR: connect_unix_sock: connect(/var/run/kamailio//kamailio_ctl): No such file or directory [2]
**solution** : remake kamailio form source using make all && make install 

**Issue 2** : unable to use fifo based commands such as kamctl dispatcher dump
ERROR: Error opening Kamailio's FIFO /var/run/kamailio/kamailio_rpc.fifo
ERROR: Make sure you have loaded the jsonrpcs module and set FIFO transport parameters
**solution** .. tbd
