## Carrier routing

The `carrierroute` module picks an outbound carrier for a call based on the dialled number. Routing
rules live in a tree keyed by a carrier and a domain, where each entry matches a prefix of the
request user and rewrites the destination. It is the usual way to build least cost routing or to
spread traffic across several upstream providers with weights and failover.

### Configuration

Rules are read from a database table rather than from the config file, so the module needs a
`db_url` and a default tree to fall back on:

```
loadmodule "db_mysql.so"
loadmodule "carrierroute.so"

modparam("carrierroute", "config_source", "db")
modparam("carrierroute", "db_url", "mysql://openser:1234@localhost/openser")
modparam("carrierroute", "carrierroute_table", "carrierroute")
modparam("carrierroute", "default_tree", "default")
modparam("carrierroute", "fetch_rows", 2000)
```

Setting `config_source` to `file` instead reads the rules from a plain text tree, which is easier
for a small static set of prefixes but requires a reload to change.

### Lookup in the routing logic

`kamailio_carrierroute.cfg` exposes the lookup as a redirect service: a request carrying the header
`X-ROUTE: LOOKUP` is answered with a 302 pointing at the carrier chosen for the dialled number,
rather than being relayed.

```
if (is_method("INVITE") && $hdr(X-ROUTE)=="LOOKUP") {
    if (!cr_route("default", "default", "$rU", "$rU", "call_id", "$avp(s:route_desc)")) {
        sl_send_reply("604", "Unable to route this call");
        exit;
    } else {
        avp_pushto("$ru/username", "$avp(s:route_desc)");
        sl_send_reply("302", "$rd");
        exit;
    }
}
```

The arguments to `cr_route()` are the carrier, the domain, the number to match, the user part to
rewrite, the hash source used to distribute traffic across equally weighted rules, and an AVP that
receives the description of the rule that matched. Using `call_id` as the hash source keeps all
requests of a dialog on the same carrier.

To relay instead of redirecting, drop the `sl_send_reply("302", ...)` and call `t_relay()` after
`cr_route()` has rewritten the request URI.

### Notes

- `mpath` in this configuration points at `/opt/kamailio/lib64/kamailio/modules/`; change it to
  match your installation, commonly `/usr/lib/x86_64-linux-gnu/kamailio/modules/` on Debian.
- The example listens on `udp:127.0.0.1:5062` and disables TCP, so it can run beside another
  Kamailio instance while you test the routing tree.
- `mi_fifo` is used for the control interface here. On Kamailio v5.x prefer `jsonrpcs` with `kamcmd`,
  see the [kamcmd notes](../kamcmd_debug.md).
