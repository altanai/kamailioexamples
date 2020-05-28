# EVAPI 

## Debugging 

**Issue 1** 0(83950) ERROR: <core> [core/sr_module.c:501]: load_module(): could not find module <evapi> in </usr/local/lib64/kamailio/modules/>
**Solution** Make the evapi so file . goto Source such as 
```
cd /kamailio/src/modules/evapi
make
```
once the evapi.so file is build then copy to module mpath location for kamilio modules 
```
cp evapi.so /usr/local/lib64/kamailio/modules/
```

**Issue 2** evapi_dispatch.c:34:10: fatal error: 'ev.h' file not found
**Solution** Install libev
```brew install libev ```
or for ubuntu systems
```bash

```

**Issue 3** could not find module <mi_fifo> in </usr/local/lib64/kamailio/modules/>
**Solution** This was a module which provides a FIFO transport layer implementation for the Management Interface.
Now removed . The jsonrpcs module can be used instead to execute RPC commands over a FIFO file.
ref : https://www.kamailio.org/wiki/install/upgrade/4.4.x-to-5.0.0

**Issue 4**  0(86149) ERROR: <core> [core/sr_module.c:501]: load_module(): could not find module <mi_rpc> in </usr/local/lib64/kamailio/modules/>
**solution**  Same as above : The internal library kmi, the modules mi_datagram, mi_fifo, mi_xmlrpc, mi_rpc and pua_mi were removed.
ref : https://www.kamailio.org/w/2017/01/mi-code-removed/

**Issue 5** Module version mismtach with core like
```
Loading modules under config path: /usr/local/lib64/kamailio/modules/
 0(86503) ERROR: <core> [core/sr_module.c:353]: version_control(): module version mismatch for /usr/local/lib64/kamailio/modules/evapi.so; core: kamailio 5.4.0-dev3 (x86_64/darwin); module: kamailio 5.4.0-dev4 (x86_64/darwin)
```
**Solution** It is more feasible to update the modules than to update the core , hence goto the git location for modules and checkout the correct branch . In this case 
```
cd kamailio
git checkout 5.3.0
sudo make all
```
and then rebuild the so file as decsribed in Issue 1 

**Isue6**  0(16513) ERROR: <core> [core/cfg.y:3400]: yyparse(): cfg. parser: failed to find command jansson_get (params 3)
**Solution**  provides operations on JSON strings using JANSSON library . Jansson is a C library for encoding, decoding and manipulating JSON data. 
```
brew install jansson 
```

**Issue7** TypeError [ERR_UNKNOWN_ENCODING]: Unknown encoding: null
**aolution** 

### References 

- http://kb.asipto.com/kamailio:k43-async-sip-routing-nodejs
- https://packages.ubuntu.com/ for Ubuntu Packages