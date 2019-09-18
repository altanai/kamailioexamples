# Account and CDR module 

Database strcutures 
```
mysql> desc acc;
+------------+------------------+------+-----+---------+----------------+
| Field      | Type             | Null | Key | Default | Extra          |
+------------+------------------+------+-----+---------+----------------+
| id         | int(10) unsigned | NO   | PRI | NULL    | auto_increment |
| method     | varchar(16)      | NO   |     |         |                |
| from_tag   | varchar(64)      | NO   |     |         |                |
| to_tag     | varchar(64)      | NO   |     |         |                |
| callid     | varchar(255)     | NO   | MUL |         |                |
| sip_code   | varchar(3)       | NO   |     |         |                |
| sip_reason | varchar(128)     | NO   |     |         |                |
| time       | datetime         | NO   |     | NULL    |                |
+------------+------------------+------+-----+---------+----------------+
8 rows in set (0.01 sec)
```
```
mysql> desc acc_cdrs;
+------------+------------------+------+-----+---------------------+----------------+
| Field      | Type             | Null | Key | Default             | Extra          |
+------------+------------------+------+-----+---------------------+----------------+
| id         | int(10) unsigned | NO   | PRI | NULL                | auto_increment |
| start_time | datetime         | NO   | MUL | 2000-01-01 00:00:00 |                |
| end_time   | datetime         | NO   |     | 2000-01-01 00:00:00 |                |
| duration   | float(10,3)      | NO   |     | 0.000               |                |
+------------+------------------+------+-----+---------------------+----------------+
```

## Maintaining dialog variables for reporting 

**Call start Time**

can set call_start_time avp varaible when INVITE from one end is recived 
```
headers.sets("$avp(call_start_time)", current_time)
```
later be converted to dialog varaible on 200 OK received from other end client 
```
local call_start_time = headers.get("$avp(call_start_time)") or "0"
```
now this can be used else where in the program till dialog exists 

**call_ring_time**

simillarly set call_ring_time if on reply route response_code > 100 and response_code < 300

**call_end_time**

set on reiving BYE or any other termination event as "dialog:end" or "dialog:failed"

At the time of reporting gather the varaibles and values such as 
```
local call_start_time = headers.get("$dlg_var(call_start_time)") or headers.get("$avp(call_start_time)") 
local call_ring_time = headers.get("$dlg_var(call_ring_time)") or headers.get("$avp(call_ring_time)") 
local call_end_time = headers.get("$dlg_var(call_end_time)") or headers.get("$avp(call_end_time)") 
```

**call_duration**

local call_duration = call_end_time - call_start_time 