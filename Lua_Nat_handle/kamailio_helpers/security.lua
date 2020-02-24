-- Security related functions

local security = {}

-- Getter/Setter, don't test

function security.is_allowed_by_permissions()
  return KSR.permissions.allow_source_address(1)>0
end

function security.is_ip_banned()
  return not KSR.pv.is_null("$sht(ipban=>$si)")
end

function security.pike_above_limit()
  return KSR.pike.pike_check_req() < 0
end

function security.ban_ip()
  KSR.pv.seti("$sht(ipban=>$si)", 1)
end

function security.is_not_authenticated()
  return KSR.auth_db.auth_check(KSR.pv.get("$fd"), "subscriber", 1) < 0
end

function security.send_auth_challenge()
  KSR.auth.auth_challenge(KSR.pv.get("$fd"), 0)
end

function security.remove_credentials()
  KSR.auth.consume_credentials()
end

-- Testworthy methods here

return security