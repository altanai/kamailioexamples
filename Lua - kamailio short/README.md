## kamailio Basic routing proxy 

sip US --> Kamailio (5060) --> sipp UAS (5080)

Note : Management Interface () mi_fifo and mi_rpc ) are depricated post v 5.x hence reoved from the sample 
ref : https://stackoverflow.com/questions/42928541/can-not-find-mi-fifo-so-and-mi-rpc-so-files-while-install-kamailio-on-sierra

sipp server 
sipp -sn uas 127.0.0.1 -p 5080

also

-- KSR - the new dynamic object exporting Kamailio functions (kemi)
-- sr - the old static object exporting Kamailio function