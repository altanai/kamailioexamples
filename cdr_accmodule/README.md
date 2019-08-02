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