# Heplify server 

## Usage of /opt/heplify-server/heplify-server:
  -alegids
    	Change value of AlegIDs. (default [])
  -cgraddr
    	Change value of CGRAddr.
  -config
    	Change value of Config. (default ./heplify-server.toml)
  -confighttpaddr
    	Change value of ConfigHTTPAddr.
  -confighttppw
    	Change value of ConfigHTTPPW.
  -customheader
    	Change value of CustomHeader. (default [])
  -dbaddr
    	Change value of DBAddr. (default localhost:3306)
  -dbbuffer
    	Change value of DBBuffer. (default 400000)
  -dbbulk
    	Change value of DBBulk. (default 400)
  -dbconftable
    	Change value of DBConfTable. (default homer_configuration)
  -dbdatatable
    	Change value of DBDataTable. (default homer_data)
  -dbdriver
    	Change value of DBDriver. (default mysql)
  -dbdropdays
    	Change value of DBDropDays. (default 14)
  -dbdropdayscall
    	Change value of DBDropDaysCall. (default 0)
  -dbdropdaysdefault
    	Change value of DBDropDaysDefault. (default 0)
  -dbdropdaysregister
    	Change value of DBDropDaysRegister. (default 0)
  -dbdroponstart
    	Change value of DBDropOnStart. (default false)
  -dbpartisup
    	Change value of DBPartIsup. (default 6h)
  -dbpartlog
    	Change value of DBPartLog. (default 2h)
  -dbpartqos
    	Change value of DBPartQos. (default 6h)
  -dbpartsip
    	Change value of DBPartSip. (default 2h)
  -dbpass
    	Change value of DBPass.
  -dbrotate
    	Change value of DBRotate. (default true)
  -dbshema
    	Change value of DBShema. (default homer5)
  -dbtablespace
    	Change value of DBTableSpace.
  -dbtimer
    	Change value of DBTimer. (default 4)
  -dbuser
    	Change value of DBUser. (default root)
  -dbworker
    	Change value of DBWorker. (default 8)
  -dedup
    	Change value of Dedup. (default false)
  -discardmethod
    	Change value of DiscardMethod. (default [])
  -esaddr
    	Change value of ESAddr.
  -esdiscovery
    	Change value of ESDiscovery. (default true)
  -espass
    	Change value of ESPass.
  -esuser
    	Change value of ESUser.
  -filterhost
    	Change value of FilterHost. (default [])
  -hepaddr
    	Change value of HEPAddr. (default 0.0.0.0:9060)
  -heptcpaddr
    	Change value of HEPTCPAddr.
  -heptlsaddr
    	Change value of HEPTLSAddr. (default 0.0.0.0:9060)
  -logdbg
    	Change value of LogDbg.
  -loglvl
    	Change value of LogLvl. (default info)
  -logstd
    	Change value of LogStd. (default false)
  -logsys
    	Change value of LogSys. (default false)
  -lokibuffer
    	Change value of LokiBuffer. (default 100000)
  -lokibulk
    	Change value of LokiBulk. (default 200)
  -lokihepfilter
    	Change value of LokiHEPFilter. (default [1 100])
  -lokitimer
    	Change value of LokiTimer. (default 2)
  -lokiurl
    	Change value of LokiURL.
  -pprofhttpaddr
    	Change value of PprofHTTPAddr.
  -promaddr
    	Change value of PromAddr. (default :9096)
  -promtargetip
    	Change value of PromTargetIP.
  -promtargetname
    	Change value of PromTargetName.

## Generated environment variables:
   HEPLIFYSERVER_ALEGIDS
   HEPLIFYSERVER_CGRADDR
   HEPLIFYSERVER_CONFIG
   HEPLIFYSERVER_CONFIGHTTPADDR
   HEPLIFYSERVER_CONFIGHTTPPW
   HEPLIFYSERVER_CUSTOMHEADER
   HEPLIFYSERVER_DBADDR
   HEPLIFYSERVER_DBBUFFER
   HEPLIFYSERVER_DBBULK
   HEPLIFYSERVER_DBCONFTABLE
   HEPLIFYSERVER_DBDATATABLE
   HEPLIFYSERVER_DBDRIVER
   HEPLIFYSERVER_DBDROPDAYS
   HEPLIFYSERVER_DBDROPDAYSCALL
   HEPLIFYSERVER_DBDROPDAYSDEFAULT
   HEPLIFYSERVER_DBDROPDAYSREGISTER
   HEPLIFYSERVER_DBDROPONSTART
   HEPLIFYSERVER_DBPARTISUP
   HEPLIFYSERVER_DBPARTLOG
   HEPLIFYSERVER_DBPARTQOS
   HEPLIFYSERVER_DBPARTSIP
   HEPLIFYSERVER_DBPASS
   HEPLIFYSERVER_DBROTATE
   HEPLIFYSERVER_DBSHEMA
   HEPLIFYSERVER_DBTABLESPACE
   HEPLIFYSERVER_DBTIMER
   HEPLIFYSERVER_DBUSER
   HEPLIFYSERVER_DBWORKER
   HEPLIFYSERVER_DEDUP
   HEPLIFYSERVER_DISCARDMETHOD
   HEPLIFYSERVER_ESADDR
   HEPLIFYSERVER_ESDISCOVERY
   HEPLIFYSERVER_ESPASS
   HEPLIFYSERVER_ESUSER
   HEPLIFYSERVER_FILTERHOST
   HEPLIFYSERVER_HEPADDR
   HEPLIFYSERVER_HEPTCPADDR
   HEPLIFYSERVER_HEPTLSADDR
   HEPLIFYSERVER_LOGDBG
   HEPLIFYSERVER_LOGLVL
   HEPLIFYSERVER_LOGSTD
   HEPLIFYSERVER_LOGSYS
   HEPLIFYSERVER_LOKIBUFFER
   HEPLIFYSERVER_LOKIBULK
   HEPLIFYSERVER_LOKIHEPFILTER
   HEPLIFYSERVER_LOKITIMER
   HEPLIFYSERVER_LOKIURL
   HEPLIFYSERVER_PPROFHTTPADDR
   HEPLIFYSERVER_PROMADDR
   HEPLIFYSERVER_PROMTARGETIP
   HEPLIFYSERVER_PROMTARGETNAME


### To hot reload 
```
killall -HUP heplify-server
```

### To start server with specific toml file 
```
./heplify-server -config /etc/heplify-server.toml &
```
