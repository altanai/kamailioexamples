# Dialog stateful proxy 

stateful proxies keep transaction states in server 
Certain applications may benefit from an awareness of "calls" in the proxy ( dialog stateful ), not just SIP transactions such as setting CPS ( calls per second )

To create the dialog associated with an initial INVITE request, execute the function “dlg_manage()” or set the flag specified by parameter “dlg_flag” before creating the corresponding transaction.
The dialog is automatically destroyed when a “BYE” is received or controlled via the default timeout and custom timeout params 

## dialog states 

1 : Unconfirmed dialog
2 : Early dialog (ringing)
3 : Confirmed dialog (waiting for ACK)
4 : Confirmed dialog (active call)
5 : Deleted dialog

## dialog profiles 

classifying, sorting and keeping track of certain types of dialogs. Can be created by programmer according to any attribute like SIP msg , pseudo-variables, custom values etc  . profile types :

**with no value** - a dialog simply belongs to a profile (for instance, an outbound calls profile). There is no other additional information to describe the dialog beyond its membership in the profile per se.
```
modparam("dialog", "profiles_no_value", "inbound ; outbound")
```
setting and unsetting  
```
set_dlg_profile("inbound_call");
unset_dlg_profile("inbound_call");
```
check if current dialog belong to aprofile 
```
if (is_in_profile("inbound_call")) {
	log("this request belongs to a inbound call\n");
}
``` 

**with value** - a dialog belongs to a profile having a certain value (like in a caller profile, where the value is the caller ID). 
```
modparam("dialog", "profiles_with_value", "caller ; my_profile")
```
setting and unsetting the profile 
```
set_dlg_profile("caller","$fu");
unset_dlg_profile("caller","$fu");
```
check if current dialog belongs to profile 
```
if (is_in_profile("caller","XX")) {
	log("this request belongs to a call of user XX\n");
}
```

Ref : https://kamailio.org/docs/modules/devel/modules/dialog.html
