## MySQL for DB storage 

Run kamdbctl create  to make the kamailio db schema 
database kamilio
```
+---------------------+
| Tables_in_kamailio  |
+---------------------+
| acc                 |
| acc_cdrs            |
| active_watchers     |
| address             |
| aliases             |
| carrier_name        |
| carrierfailureroute |
| carrierroute        |
| cpl                 |
| dbaliases           |
| dialog              |
| dialog_vars         |
| dialplan            |
| dispatcher          |
| domain              |
| domain_attrs        |
| domain_name         |
| domainpolicy        |
| dr_gateways         |
| dr_groups           |
| dr_gw_lists         |
| dr_rules            |
| globalblacklist     |
| grp                 |
| htable              |
| imc_members         |
| imc_rooms           |
| lcr_gw              |
| lcr_rule            |
| lcr_rule_target     |
| location            |
| location_attrs      |
| missed_calls        |
| mohqcalls           |
| mohqueues           |
| mtree               |
| mtrees              |
| pdt                 |
| pl_pipes            |
| presentity          |
| pua                 |
| purplemap           |
| re_grp              |
| rls_presentity      |
| rls_watchers        |
| rtpengine           |
| rtpproxy            |
| sca_subscriptions   |
| silo                |
| sip_trace           |
| speed_dial          |
| subscriber          |
| topos_d             |
| topos_t             |
| trusted             |
| uacreg              |
| uid_credentials     |
| uid_domain          |
| uid_domain_attrs    |
| uid_global_attrs    |
| uid_uri             |
| uid_uri_attrs       |
| uid_user_attrs      |
| uri                 |
| userblacklist       |
| usr_preferences     |
| version             |
| watchers            |
| xcap                |
+---------------------+
```
Add domain 
```
>kamctl domain add x.x.x.x
INFO: execute '/usr/local/sbin/kamctl domain reload' to synchronize cache and database
```
show domains 
```
>kamctl domain showdb 
+----+---------------+------+---------------------+
| id | domain        | did  | last_modified       |
+----+---------------+------+---------------------+
|  1 | x.x.x.x       | NULL | 2019-07-16 05:01:16 |
+----+---------------+------+---------------------+
```

## Storing users in location 
```
+---------------+------------------+------+-----+---------------------+----------------+
| Field         | Type             | Null | Key | Default             | Extra          |
+---------------+------------------+------+-----+---------------------+----------------+
| id            | int(10) unsigned | NO   | PRI | NULL                | auto_increment |
| ruid          | varchar(64)      | NO   | UNI |                     |                |
| username      | varchar(64)      | NO   | MUL |                     |                |
| domain        | varchar(64)      | YES  |     | NULL                |                |
| contact       | varchar(512)     | NO   |     |                     |                |
| received      | varchar(128)     | YES  |     | NULL                |                |
| path          | varchar(512)     | YES  |     | NULL                |                |
| expires       | datetime         | NO   | MUL | 2030-05-28 21:32:15 |                |
| q             | float(10,2)      | NO   |     | 1.00                |                |
| callid        | varchar(255)     | NO   |     | Default-Call-ID     |                |
| cseq          | int(11)          | NO   |     | 1                   |                |
| last_modified | datetime         | NO   |     | 2000-01-01 00:00:01 |                |
| flags         | int(11)          | NO   |     | 0                   |                |
| cflags        | int(11)          | NO   |     | 0                   |                |
| user_agent    | varchar(255)     | NO   |     |                     |                |
| socket        | varchar(64)      | YES  |     | NULL                |                |
| methods       | int(11)          | YES  |     | NULL                |                |
| instance      | varchar(255)     | YES  |     | NULL                |                |
| reg_id        | int(11)          | NO   |     | 0                   |                |
| server_id     | int(11)          | NO   | MUL | 0                   |                |
| connection_id | int(11)          | NO   |     | 0                   |                |
| keepalive     | int(11)          | NO   |     | 0                   |                |
| partition     | int(11)          | NO   |     | 0                   |                |
+---------------+------------------+------+-----+---------------------+----------------+
```

after Register location is stored in DB as 
example location stored for two users kate and altanai
```
select * from location;
+----+---------------------+----------+--------+---------------------------------------------------------------------------+--------------------------+------+---------------------+-------+--------------------------------------------------+------+---------------------+-------+--------+----------------------------------+------------------------+---------+----------+--------+-----------+---------------+-----------+-----------+
| id | ruid                | username | domain | contact                                                                   | received                 | path | expires             | q     | callid                                           | cseq | last_modified       | flags | cflags | user_agent                       | socket                 | methods | instance | reg_id | server_id | connection_id | keepalive | partition |
+----+---------------------+----------+--------+---------------------------------------------------------------------------+--------------------------+------+---------------------+-------+--------------------------------------------------+------+---------------------+-------+--------+----------------------------------+------------------------+---------+----------+--------+-----------+---------------+-----------+-----------+
|  2 | uloc-5d2d72f6-f31-2 | kate     | NULL   | sip:kate@local_addr:55093;rinstance=b40d1fb00be9a19c                    | sip:local_addr:55093   | NULL | 2019-07-16 07:52:25 | -1.00 | 97576MmQyMWQ2ZGM3Njk2MmYxNzQ4NDAwNmYwZjJiOTg2Y2I |    5 | 2019-07-16 06:52:25 |     0 |     64 | X-Lite release 5.5.0 stamp 97576 | udp:rgistrar_addr:5060 |    4831 | NULL     |      0 |         0 |            -1 |         1 |        27 |
|  3 | uloc-5d2d72f6-f35-3 | altanai  | NULL   | sip:altanai@local_addr:22053;transport=udp;rinstance=c3c9050a6dd1efba | sip:local_addr:22053 | NULL | 2019-07-16 07:52:48 | -1.00 | ZGI3NjlkYjkwYjRkZjdhMGQwOTc5Yjk2Yzg4ZTg5ZmE      |    3 | 2019-07-16 06:52:48 |     0 |     64 | Bria 3 release 3.5.5 stamp 71243 | udp:rgistrar_addr:5060 |    5087 | NULL     |      0 |         0 |            -1 |         1 |        28 |
+----+---------------------+----------+--------+---------------------------------------------------------------------------+--------------------------+------+---------------------+-------+--------------------------------------------------+------+---------------------+-------+--------+----------------------------------+------------------------+---------+----------+--------+-----------+---------------+-----------+-----------+
```


## Storing dialoges in DB
```
+------------------+------------------+------+-----+---------+----------------+
| Field            | Type             | Null | Key | Default | Extra          |
+------------------+------------------+------+-----+---------+----------------+
| id               | int(10) unsigned | NO   | PRI | NULL    | auto_increment |
| hash_entry       | int(10) unsigned | NO   | MUL | NULL    |                |
| hash_id          | int(10) unsigned | NO   |     | NULL    |                |
| callid           | varchar(255)     | NO   |     | NULL    |                |
| from_uri         | varchar(128)     | NO   |     | NULL    |                |
| from_tag         | varchar(64)      | NO   |     | NULL    |                |
| to_uri           | varchar(128)     | NO   |     | NULL    |                |
| to_tag           | varchar(64)      | NO   |     | NULL    |                |
| caller_cseq      | varchar(20)      | NO   |     | NULL    |                |
| callee_cseq      | varchar(20)      | NO   |     | NULL    |                |
| caller_route_set | varchar(512)     | YES  |     | NULL    |                |
| callee_route_set | varchar(512)     | YES  |     | NULL    |                |
| caller_contact   | varchar(128)     | NO   |     | NULL    |                |
| callee_contact   | varchar(128)     | NO   |     | NULL    |                |
| caller_sock      | varchar(64)      | NO   |     | NULL    |                |
| callee_sock      | varchar(64)      | NO   |     | NULL    |                |
| state            | int(10) unsigned | NO   |     | NULL    |                |
| start_time       | int(10) unsigned | NO   |     | NULL    |                |
| timeout          | int(10) unsigned | NO   |     | 0       |                |
| sflags           | int(10) unsigned | NO   |     | 0       |                |
| iflags           | int(10) unsigned | NO   |     | 0       |                |
| toroute_name     | varchar(32)      | YES  |     | NULL    |                |
| req_uri          | varchar(128)     | NO   |     | NULL    |                |
| xdata            | varchar(512)     | YES  |     | NULL    |                |
+------------------+------------------+------+-----+---------+----------------+
```
table dialog_vars
```
+--------------+------------------+------+-----+---------+----------------+
| Field        | Type             | Null | Key | Default | Extra          |
+--------------+------------------+------+-----+---------+----------------+
| id           | int(10) unsigned | NO   | PRI | NULL    | auto_increment |
| hash_entry   | int(10) unsigned | NO   | MUL | NULL    |                |
| hash_id      | int(10) unsigned | NO   |     | NULL    |                |
| dialog_key   | varchar(128)     | NO   |     | NULL    |                |
| dialog_value | varchar(512)     | NO   |     | NULL    |                |
+--------------+------------------+------+-----+---------+----------------+sele
```
Dialog 
```
select * from dialog;
+----+------------+---------+--------------------------------------------------+------------------------+----------+---------------------------+----------+-------------+-------------+------------------+------------------+-----------------------------------------------------------------------------------+-----------------------------------------------------------+------------------------+------------------------+-------+------------+------------+--------+--------+--------------+-------------------------------------------------------------------------+-------+
| id | hash_entry | hash_id | callid                                           | from_uri               | from_tag | to_uri                    | to_tag   | caller_cseq | callee_cseq | caller_route_set | callee_route_set | caller_contact                                                                    | callee_contact                                            | caller_sock            | callee_sock            | state | start_time | timeout    | sflags | iflags | toroute_name | req_uri                                                                 | xdata |
+----+------------+---------+--------------------------------------------------+------------------------+----------+---------------------------+----------+-------------+-------------+------------------+------------------+-----------------------------------------------------------------------------------+-----------------------------------------------------------+------------------------+------------------------+-------+------------+------------+--------+--------+--------------+-------------------------------------------------------------------------+-------+
|  1 |       2532 |    3569 | 97576M2U1N2VmNGYxM2U2YjAxOWRlNmEwNTU2NTdhZWU0MmI | sip:kate@registrar_addr | eeaa9e39 | sip:altanai@registrar_addr | b3f93416 | 1           | 0           | NULL             | NULL             | sip:kate@local_addr:25797;rinstance=4343a1eb7a321c75;alias=local_addr~25797~1 | sip:altanai@local_addr:35570;alias=local_addr~35570~1 | udp:rgistrar_addr:5060 | udp:rgistrar_addr:5060 |     4 | 1563268176 | 1563311376 |      0 |      0 | NULL         | sip:altanai@local_addr:35570;transport=udp;rinstance=1a0e6707dc2a6a25 | NULL  |
+----+------------+---------+--------------------------------------------------+------------------------+----------+---------------------------+----------+-------------+-------------+------------------+------------------+-----------------------------------------------------------------------------------+-----------------------------------------------------------+------------------------+------------------------+-------+------------+------------+--------+--------+--------------+-------------------------------------------------------------------------+-------+
```

## Debug 

Issue 1 : call responds with  488 Not Acceptable Here.
Check if the codecs are matched and whther RTP proxy is connected .
In route[NATMANAGE]  check for logs like 
```
ERROR: rtpproxy [rtpproxy.c:1478]: send_rtpp_command(): can't send command to a RTP proxy
{1 1 INVITE 97576ZGM1ZjU5MmQ3ZDhmMTA4MzU5NDZjN2Q2N2U2MmIwNTE}  8(3896) ERROR: rtpproxy [rtpproxy.c:1513]: send_rtpp_command(): proxy <udp:127.0.0.1:7722> does not respond, disable it
{1 1 INVITE 97576ZGM1ZjU5MmQ3ZDhmMTA4MzU5NDZjN2Q2N2U2MmIwNTE}  8(3896) WARNING: rtpproxy [rtpproxy.c:1370]: rtpp_test(): can't get version of the RTP proxy
{1 1 INVITE 97576ZGM1ZjU5MmQ3ZDhmMTA4MzU5NDZjN2Q2N2U2MmIwNTE}  8(3896) WARNING: rtpproxy [rtpproxy.c:1406]: rtpp_test(): support for RTP proxy <udp:127.0.0.1:7722> has been disabled temporarily
{1 1 INVITE 97576ZGM1ZjU5MmQ3ZDhmMTA4MzU5NDZjN2Q2N2U2MmIwNTE}  8(3896) ERROR: rtpproxy [rtpproxy.c:2498]: force_rtp_proxy(): no available proxies
```
solution : inspect rtpproxy runing and reconnect it

