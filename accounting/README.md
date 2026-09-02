## Accounting and CDRs

Accounting records what happened on the server: who called whom, when the call started and ended,
and how the transaction finished. Kamailio produces these records with the `acc` module, which can
write to syslog, to a database, or to an external system such as RADIUS or DIAMETER.

Accounting is driven by flags set during routing rather than by a global switch. Three flags decide
what is recorded:

```
#!define FLT_ACC 1          # account the transaction
#!define FLT_ACCMISSED 2    # account calls that were never answered
#!define FLT_ACCFAILED 3    # account transactions that ended with a failure reply
```

### Files

| File | Purpose |
|------|---------|
| `kamailo_account.cfg` | Log-only accounting. INVITEs are flagged with `FLT_ACC`, records go to syslog through `log_flag`. No database is required. |
| `kamailio-advanced.cfg` | Full configuration with MySQL backed accounting, enabled by defining `WITH_ACCDB`, plus the `ALTER TABLE` statements for the extra `acc` columns. |

### Log accounting

The minimal setup only needs `acc.so` loaded and a flag set on the requests to be accounted:

```
loadmodule "acc.so"

modparam("acc", "log_flag", FLT_ACC)
modparam("acc", "log_missed_flag", FLT_ACCMISSED)
modparam("acc", "failed_transaction_flag", FLT_ACCFAILED)
modparam("acc", "log_extra",
    "src_user=$fU;src_domain=$fd;src_ip=$si;dst_ouser=$tU;dst_user=$rU;dst_domain=$rd")

request_route {
    # account only INVITEs
    if (is_method("INVITE")) {
        setflag(FLT_ACC);
    }
    ...
}
```

`log_extra` controls which pseudo-variables end up in the record beyond the defaults. Because the
values are read when the transaction completes, use variables that are still meaningful at that
point.

### Database accounting

Writing to MySQL only changes where the record goes; the flags stay the same:

```
#!define WITH_ACCDB

modparam("acc", "db_flag", FLT_ACC)
modparam("acc", "db_missed_flag", FLT_ACCMISSED)
modparam("acc", "db_url", DBURL)
```

The stock `acc` table does not have columns for the extra fields, so add them before enabling
`db_extra`:

```sql
ALTER TABLE acc ADD COLUMN src_user VARCHAR(64) NOT NULL DEFAULT '';
ALTER TABLE acc ADD COLUMN src_domain VARCHAR(128) NOT NULL DEFAULT '';
ALTER TABLE acc ADD COLUMN src_ip varchar(64) NOT NULL default '';
ALTER TABLE acc ADD COLUMN dst_ouser VARCHAR(64) NOT NULL DEFAULT '';
ALTER TABLE acc ADD COLUMN dst_user VARCHAR(64) NOT NULL DEFAULT '';
ALTER TABLE acc ADD COLUMN dst_domain VARCHAR(128) NOT NULL DEFAULT '';
```

The same statements are needed on the `missed_calls` table if missed call accounting is enabled.

### What gets accounted

- `early_media` records 183 Session Progress as an answer. Off by default, since it inflates
  answered call counts.
- `report_ack` and `report_cancels` add records for ACK and CANCEL, useful for debugging but noisy
  in production.
- `detect_direction` decides whether the caller is taken from the From header or from the direction
  of the request, which matters for in-dialog BYEs.

### Related examples

- [mos_cdr_accmodule](../mos_cdr_accmodule/) writes voice quality scores next to the CDR.
- [mos_rtpstats_rtpengine](../mos_rtpstats_rtpengine/) derives MOS from RTCP statistics.
- [mysql_user_stoarge](../mysql_user_stoarge/) covers the MySQL schema setup with `kamctl`.
