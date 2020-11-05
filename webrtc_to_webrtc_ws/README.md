# Websocket protocol supported Kamailio server suited for WebRTC clients 

used server  - Kamailio (OpenSER) SIP Server v5.3 


### SSL certs using 

creating file paths 
```
mkdir certs
mkdir certs/private
mkdir certs/newcerts
touch certs/index.txt
echo 01 >certs/serial
echo 01 >certs/crlnumber
```

list the files 
```
/home/ubuntu/certs# ls
crlnumber  index.txt  newcerts  private  serial
```

create ca private key
```
openssl genrsa -out certs/private/cakey.pem 2048
chmod 600 certs/private/cakey.pem
```

create ca self signed certificate
```
openssl req -out certs/cacert.pem -x509 -new -key certs/private/cakey.pem
```

create server / client certificate, a private key (by name privkey.pem)
```
openssl req -out kamailio1_cert_req.pem -new -nodes
openssl ca -in kamailio1_cert_req.pem -out kamailio1_cert.pem
```

output should be like 
...
Certificate is to be certified until Jun 25 11:02:41 2020 GMT (365 days)
Sign the certificate? [y/n]:y
1 out of 1 certificate requests certified, commit? [y/n]y
Write out database with 1 new entries
Data Base Updated

and files genrated shoudl look like

/home/ubuntu# ls 
 certs  kamailio1_cert.pem kamailio1_cert_req.pem privkey.pem

copy the newly created certs to their respective paths
```
mkdir /etc/pki/CA/
cp kamailio1_cert.pem /etc/pki/CA/
cp privkey.pem /etc/pki/CA/
```
make list of ca certs by finding all cacerts across root directory and appending them to a catlist pem
```
find / -name cacert.pem
cat /usr/share/doc/libssl-doc/demos/cms/cacert.pem >> /home/ubuntu/catlist.pem
cat /usr/share/doc/libssl-doc/demos/smime/cacert.pem >> /home/ubuntu/catlist.pem
cat /home/ubuntu/kamailio_source_code/misc/tls-ca/rootCA/cacert.pem >> /home/ubuntu/catlist.pem
...
cp /home/ubuntu/catlist.pem /etc/pki/CA/
```

update kamailio.cfg  
```
modparam("tls", "certificate", "/etc/pki/CA/kamailio1_cert.pem")
modparam("tls", "private_key", "/etc/pki/CA/privkey.pem")
modparam("tls", "ca_list", "/etc/pki/CA/calist.pem")
```

### Compiling and loading websocket module into kamailio.cfg

goto source folder -> modules -> websocket and compile 
```
cd /home/ubuntu/kamailio_source_code/src/modules/websocket
make && make install
```
check websocket.io in module directory 
```
ls /usr/local/lib64/kamailio//modules/websodket.io
```
include in kamailio.cfg
```
loadmodule "websocket.so"
```

ref : https://loadmultiplier.com/node/236


## Kamcmd lookups

Get info about open sockets 
```sh
kamcmd> core.sockets_list
{
	socket: {
		proto: udp
		address: 1.2.3.4
		port: 5060
		mcast: no
		mhomed: no
	}
	socket: {
		proto: tcp
		address:  1.2.3.4
		port: 5060
		mcast: no
		mhomed: no
	}
	socket: {
		proto: tcp
		address:  1.2.3.4
		port: 80
		mcast: no
		mhomed: no
	}
	socket: {
		proto: tls
		address:  1.2.3.4
		port: 5061
		mcast: no
		mhomed: no
	}
	socket: {
		proto: tls
		address:  1.2.3.4
		port: 443
		mcast: no
		mhomed: no
	}
}
```


## debugging help 

**Issue1** error on save command
```shell script
		if (!save("location")) {
			sl_reply_error();
		}
: cfg. parser: failed to find command save (params 1)
```
\
**solution** rebuild registrar module , check the version of core kamailio and modules 



**Ref** :
- Websocket mod - http://kamailio.org/docs/modules/stable/modules/websocket.html
