# kamcmd_debug

## kamcmd commands

cfg.list
rtpengine: rtpengine_disable_tout
rtpengine: aggressive_redetection
rtpengine: rtpengine_tout_ms
rtpengine: queried_nodes_limit
rtpengine: rtpengine_retr
websocket: keepalive_timeout
websocket: enabled
tls: force_run
tls: method
tls: server_name
tls: server_name_mode
tls: server_id
tls: verify_certificate
tls: verify_depth
tls: require_certificate
tls: private_key
tls: ca_list
tls: crl
tls: certificate
tls: cipher_list
tls: session_cache
tls: session_id
tls: config
tls: log
tls: debug
tls: connection_timeout
tls: disable_compression
tls: ssl_release_buffers
tls: ssl_free_list_max
tls: ssl_max_send_fragment
tls: ssl_read_ahead
tls: low_mem_threshold1
tls: low_mem_threshold2
tls: ct_wq_max
tls: con_ct_wq_max
tls: ct_wq_blk_size
tls: send_close_notify
xlog: methods_filter
siputils: ring_timeout
registrar: realm_pref
registrar: default_expires
registrar: default_expires_range
registrar: expires_range
registrar: min_expires
registrar: max_expires
registrar: max_contacts
registrar: retry_after
registrar: case_sensitive
registrar: default_q
registrar: append_branches
maxfwd: max_limit
tm: auto_inv_100_reason
tm: default_reason
tm: ac_extra_hdrs
tm: ruri_matching
tm: via1_matching
tm: callid_matching
tm: fr_timer
tm: fr_inv_timer
tm: fr_inv_timer_next
tm: wt_timer
tm: delete_timer
tm: retr_timer1
tm: retr_timer2
tm: max_inv_lifetime
tm: max_noninv_lifetime
tm: noisy_ctimer
tm: auto_inv_100
tm: unix_tx_timeout
tm: restart_fr_on_each_reply
tm: pass_provisional_replies
tm: aggregate_challenges
tm: unmatched_cancel
tm: default_code
tm: reparse_invite
tm: blst_503
tm: blst_503_def_timeout
tm: blst_503_min_timeout
tm: blst_503_max_timeout
tm: blst_methods_add
tm: blst_methods_lookup
tm: cancel_b_method
tm: reparse_on_dns_failover
tm: disable_6xx_block
tm: local_ack_mode
tm: local_cancel_reason
tm: e2e_cancel_reason
tm: relay_100
tcp: connect_timeout
tcp: send_timeout
tcp: connection_lifetime
tcp: max_connections
tcp: max_tls_connections
tcp: no_connect
tcp: fd_cache
tcp: async
tcp: connect_wait
tcp: conn_wq_max
tcp: wq_max
tcp: defer_accept
tcp: delayed_ack
tcp: syncnt
tcp: linger2
tcp: keepalive
tcp: keepidle
tcp: keepintvl
tcp: keepcnt
tcp: crlf_ping
tcp: accept_aliases
tcp: alias_flags
tcp: new_conn_alias_flags
tcp: accept_no_cl
tcp: reuse_port
tcp: rd_buf_size
tcp: wq_blk_size
core: debug
core: log_facility
core: memdbg
core: use_dst_blacklist
core: dst_blacklist_expire
core: dst_blacklist_mem
core: dst_blacklist_udp_imask
core: dst_blacklist_tcp_imask
core: dst_blacklist_tls_imask
core: dst_blacklist_sctp_imask
core: dns_try_ipv6
core: dns_try_naptr
core: dns_udp_pref
core: dns_tcp_pref
core: dns_tls_pref
core: dns_sctp_pref
core: dns_retr_time
core: dns_retr_no
core: dns_servers_no
core: dns_use_search_list
core: dns_search_full_match
core: dns_reinit
core: dns_naptr_ignore_rfc
core: use_dns_cache
core: dns_cache_flags
core: use_dns_failover
core: dns_srv_lb
core: dns_cache_negative_ttl
core: dns_cache_min_ttl
core: dns_cache_max_ttl
core: dns_cache_mem
core: dns_cache_del_nonexp
core: dns_cache_rec_pref
core: mem_dump_pkg
core: mem_dump_shm
core: max_while_loops
core: udp_mtu
core: udp_mtu_try_proto
core: udp4_raw
core: udp4_raw_mtu
core: udp4_raw_ttl
core: force_rport
core: memlog
core: mem_summary
core: mem_safety
core: mem_join
core: mem_status_mode
core: corelog
core: latency_cfg_log
core: latency_log
core: latency_limit_db
core: latency_limit_action
core: pv_cache_limit
core: pv_cache_action

## ul.dump

```
{
	Domains: {
		Domain: {
			Domain: location
			Size: 1024
			AoRs: {
				Info: {
					AoR: altanai
					HashID: 1840696046
					Contacts: {
						Contact: {
							Address: sip:altanai@ua_ip:1958;transport=udp;rinstance=dc21050575a72185
							Expires: 47
							Q: -1.000000
							Call-ID: CDMlBCwTCSRgHWa88bi1yA..
							CSeq: 21
							User-Agent: Z 5.2.28 rv2.8.115
							Received: [not set]
							Path: [not set]
							State: CS_DIRTY
							Flags: 0
							CFlags: 0
							Socket: udp:uas_ip:5060
							Methods: 5087
							Ruid: uloc-5d42f164-11b9-f
							Instance: [not set]
							Reg-Id: 0
							Server-Id: 0
							Tcpconn-Id: -1
							Keepalive: 0
							Last-Keepalive: 1564669361
							Last-Modified: 1564669361
						}
					}
				}
				Info: {
					AoR: alice
					HashID: 1834153949
					Contacts: {
						Contact: {
							Address: sip:qj954ri6@9g6c7ijt6p1e.invalid;transport=ws
							Expires: 575
							Q: -1.000000
							Call-ID: tcet5dlavm0fmdmo0u2mhc
							CSeq: 50
							User-Agent: JsSIP 3.1.2
							Received: sip:ip:59118;transport=ws
							Path: [not set]
							State: CS_DIRTY
							Flags: 0
							CFlags: 64
							Socket: tls:uas_ip:443
							Methods: 6943
							Ruid: uloc-5d41ccd1-7746-4
							Instance: <urn:uuid:aa7ec11b-4fc3-4ea4-ad62-f4a647b2a8c3>
							Reg-Id: 1
							Server-Id: 0
							Tcpconn-Id: 8
							Keepalive: 1
							Last-Keepalive: 1564669349
							Last-Modified: 1564669349
						}
						Contact: {
							Address: sip:g9pcgu2p@1o5698r71kb6.invalid;transport=ws
							Expires: 315
							Q: -1.000000
							Call-ID: lhco49lh1pk5cjnfgn630n
							CSeq: 2
							User-Agent: JsSIP 3.1.2
							Received: sip:ua_ip:2042;transport=ws
							Path: [not set]
							State: CS_SYNC
							Flags: 0
							CFlags: 64
							Socket: tls:uas_ip:443
							Methods: 6943
							Ruid: uloc-5d42f164-11d0-4
							Instance: <urn:uuid:96c56e1d-4d22-4e0f-9812-ad1ff7c1dcc3>
							Reg-Id: 1
							Server-Id: 0
							Tcpconn-Id: -1
							Keepalive: 1
							Last-Keepalive: 1564669089
							Last-Modified: 1564669089
						}
					}
				}
			}
			Stats: {
				Records: 6
				Max-Slots: 1
			}
		}
	}
}
```

## Issues

### Issue 1 
ERROR: connect_unix_sock: connect(/var/run/kamailio//kamailio_ctl): No such file or directory [2]
**solution** add ctl module to kamailio config 
```
loadmodule "ctl.so"
...
modparam("ctl", "binrpc", "tcp:MY_IP_ADDR:2046")
modparam("ctl", "binrpc", "unix:/var/run/kamailio/kamailio_ctl") # default
```

