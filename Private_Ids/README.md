# P-Asserted-Identity and Remote-Party-ID header

Masking identity information at the originating user agent by adding From header such as Anaonymous
caller privacy , not be identifiable by recipients of the call
privacy and identity in Trust Domains
prevent call tracking from PSTN or illegal intermediaries

##P-Asserted-Identity header 

used among trusted SIP
entities (typically intermediaries) to carry the identity of the user
sending a SIP message as it was verified by authentication.

Headers  P-Asserted-Identity contains caller Id info like URI  and an optional display-name
```
P-Asserted-Identity: "Altanai" <sip:altanai@telecom.com>
```
A proxy server which handles a message can insert such a P-Asserted-Identity header field into the message and forward it to other trusted proxies.  


##P-Preferred-Identity header 

used from a user agent to a trusted proxy to carry the identity the user sending the SIP message  wishes to be used for the P-Asserted-Header field value that the trusted element will insert.
user agent only sends a P-Preferred-Identity header field to proxy servers in a Trust Domain

When a trusted entity sends a message to any destination with that party's identity in a P-Asserted-Identity header field, the entity MUST take precautions to protect the identity information from eavesdropping and interception to protect the confidentiality and integrity of that identity information. 


## Kamailio pseudo variable 


$ai - URI inP-Asserted-Identity header
reference to URI in request's P-Asserted-Identity header (see RFC 3325)

$pU - User in P-Preferred-Identity header URI
reference to user in request's P-Preferred-Identity header URI (see RFC 3325)

$pu - URI in P-Preferred-Identity header
reference to URI in request's P-Preferred-Identity header (see RFC 3325)


Ref :
Private Extensions to the Session Initiation Protocol (SIP) for Asserted Identity within Trusted Networks - https://tools.ietf.org/html/rfc3325


