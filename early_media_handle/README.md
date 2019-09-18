# Early Media Handling 

## RFC on early media 

Early Media is the ability of two SIP user agents to communicate before a SIP call is actually established.
Common cases where called party is PSTN gateway and plays inband tones or announcements before the call is set up , mostly to share call progress information with caller.
Can also be used in IVR cases when caller needs to enter DTMF digit in order to connect to final destination after dialing a toll free ( 80's ) number 

Early media usually comes aling with 183 Ringing and not 200 , since a 2xx class response to an INVITE both establishes a media session, and indicates acceptance of the call , where as early media only estalishes media not answer the call

Ref :

https://tools.ietf.org/html/draft-rosenberg-sip-early-media-00
