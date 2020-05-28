# DB SQLite Database for Kamailio 

By default, an SQLite session uses the in-memory database, therefore, all changes will be gone when the session ends.


## Installation 
```bash
cd kamailio_sourcecode/src/modules/db_sqlite
make && make install 
```

and also install SQLlite3 server 
```bash
apt install sqlite3
```

To open the cmd console write sqlite3
```bash
# sqlite3
SQLite version 3.22.0 2018-01-22 18:45:57
Enter ".help" for usage hints.
Connected to a transient in-memory database.
Use ".open FILENAME" to reopen on a persistent database.
sqlite> .database
main: 
```

## Using sqlite 

To open a database file, you use the .open FILENAME command. 


### using kamdbctl 

kamdbctl is a script to maintain the database needed by some Kamalio modules.

without specifying a database engine 
```bash
kamdbctl
ERROR: database engine not specified, please setup one in the config script
```

Update kamctlrc withe engine such as BENGINE=SQLITE

find kamctlrc
```bash
sudo find / -name kamctlrc
```

My kamctlrc is at location /usr/local/etc/kamailio/kamctlrc
```bash
## the SIP domain
# SIP_DOMAIN=kamailio.org

## chrooted directory
# CHROOT_DIR="/path/to/chrooted/directory"

## database type: MYSQL, PGSQL, ORACLE, DB_BERKELEY, DBTEXT, or SQLITE
## by default none is loaded
##
## If you want to setup a database with kamdbctl, you must at least specify
## this parameter.
# DBENGINE=MYSQL
DBENGINE=SQLITE
## database host
# DBHOST=localhost

## database port
# DBPORT=3306

## database name (for ORACLE this is TNS name)
# DBNAME=kamailio

## database path used by dbtext, db_berkeley or sqlite
# DB_PATH="/usr/local/etc/kamailio/dbtext"

## database read/write user
# DBRWUSER="kamailio"

## password for database read/write user
# DBRWPW="kamailiorw"

## database read only user
# DBROUSER="kamailioro"

```

create tables
```bash
> kamdbctl create kamailio.db
INFO: creating database kamailio.db ...
INFO: Core Kamailio tables succesfully created.
Install presence related tables? (y/n): y
INFO: creating presence tables into kamailio.db ...
INFO: Presence tables succesfully created.
Install tables for imc cpl siptrace domainpolicy carrierroute
		drouting userblacklist htable purple uac pipelimit mtree sca mohqueue
		rtpproxy rtpengine? (y/n): y
INFO: creating extra tables into kamailio.db ...
INFO: Extra tables succesfully created.

```
Then give the location of create DB to kamailio config such as 
```bash
/usr/local/sbin/kamailio.db
```

## Debugging 

**Issue1** db not opened 
```bash
0(17314) ERROR: db_sqlite [dbase.c:79]: db_sqlite_new_connection(): failed to open sqlite database '/etc/kamailio/kamailio.db'
```
**Solution** ensure that sqlite is installed 
```bash
apt install sqlite3
```

**Issue 2** could not load the script kamdbctl.sqlite
```bash
-e \E[37;31mERROR: could not load the script in /usr/local/lib64/kamailio//kamctl/kamdbctl.sqlite for database engine SQLITE
-e \E[37;31mERROR: database engine not loaded - tried 'SQLITE'
```