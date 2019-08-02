# sipSAK

comand line tool for SIP stress and diagnostics 

## Features
sending OPTIONS request
sending text files (which should contain SIP requests)
traceroute (see section 11 in RFC3261)
user location test
flooding test
random character trashed test
interpret and react on response
authentication with qop supported
short notation supported for receiving (not for sending)
string replacement in files
can simulate calls in usrloc mode
uses symmetric signaling and thus should work behind NAT

## modes 

* default mode - A SIP message is sent to destination in sip-uri and reply status is displayed.
* traceroute mode (-T) - learning request's path ( IP traceroute)
* message mode (-M) - Sends a short message (similar to SMS from the mobile phones) to a given target. 
* usrloc mode (-U) - stress mode for SIP registrar. sipsak keeps registering to a SIP server at high pace. Additionaly the registrar can be stressed with the -I or the -M option. If -I and -M are omitted sipsak can be used to register any given contact (with the -C option) for an account at a registrar and to query the current bindings for an account at a registrar.
* randtrash mode (-R) - Parser torture mode. sipsak keeps sending randomly corrupted messages to torture a SIP server's parser.
* flood mode (-F) - Stress mode for SIP servers. sipsak keeps sending requests to a SIP server at high pace.

## setup

Install
```
apt-get install heartbeat sipsak
```
Commands 
```
 shoot  : sipsak [-f FILE] [-L] -s SIPURI
 trace  : sipsak -T -s SIPURI
 usrloc : sipsak -U [-I|M] [-b NUMBER] [-e NUMBER] [-x NUMBER] [-z NUMBER] -s SIPURI
 usrloc : sipsak -I|M [-b NUMBER] [-e NUMBER] -s SIPURI
 usrloc : sipsak -U [-C SIPURI] [-x NUMBER] -s SIPURI
 message: sipsak -M [-B STRING] [-O STRING] [-c SIPURI] -s SIPURI
 flood  : sipsak -F [-e NUMBER] -s SIPURI
 random : sipsak -R [-t NUMBER] -s SIPURI

 additional parameter in every mode:
   [-a PASSWORD] [-d] [-i] [-H HOSTNAME] [-l PORT] [-m NUMBER] [-n] [-N]
   [-r PORT] [-v] [-V] [-w]

  -h                displays this help message
  -V                prints version string only
  -f FILE           the file which contains the SIP message to send
                      use - for standard input
  -L                de-activate CR (\r) insertion in files
  -s SIPURI         the destination server uri in form
                      sip:[user@]servername[:port]
  -T                activates the traceroute mode
  -U                activates the usrloc mode
  -I                simulates a successful calls with itself
  -M                sends messages to itself
  -C SIPURI         use the given uri as Contact in REGISTER
  -b NUMBER         the starting number appendix to the user name (default: 0)
  -e NUMBER         the ending numer of the appendix to the user name
  -o NUMBER         sleep number ms before sending next request
  -x NUMBER         the expires header field value (default: 15)
  -z NUMBER         activates randomly removing of user bindings
  -F                activates the flood mode
  -R                activates the random modues (dangerous)
  -t NUMBER         the maximum number of trashed character in random mode
                      (default: request length)
  -l PORT           the local port to use (default: any)
  -r PORT           the remote port to use (default: 5060)
  -p HOSTNAME       request target (outbound proxy)
  -H HOSTNAME       overwrites the local hostname in all headers
  -m NUMBER         the value for the max-forwards header field
  -n                use FQDN instead of IPs in the Via-Line
  -i                deactivate the insertion of a Via-Line
  -a PASSWORD       password for authentication
                      (if omitted password="")
  -u STRING         Authentication username
  -d                ignore redirects
  -v                each v produces more verbosity (max. 3)
  -w                extract IP from the warning in reply
  -g STRING         replacement for a special mark in the message
  -G                activates replacement of variables
  -N                returns exit codes Nagios compliant
  -q STRING         search for a RegExp in replies and return error
                    on failure
  -W NUMBER         return Nagios warning if retrans > number
  -B STRING         send a message with string as body
  -O STRING         Content-Disposition value
  -P NUMBER         Number of processes to start
  -A NUMBER         number of test runs and print just timings
  -S                use same port for receiving and sending
  -c SIPURI         use the given uri as From in MESSAGE
  -D NUMBER         timeout multiplier for INVITE transactions
                    and reliable transports (default: 64)
  -E STRING         specify transport to be used
  -j STRING         adds additional headers to the request
```

Ref : https://blog.voipxswitch.com/2017/12/26/kamailio-high-availability-using-keepalived/