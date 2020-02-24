--- Traffic related functions
local traffic = {
}

-- Getter/Setter, don't test

function traffic.is_request_from_local()
  return KSR.is_myself(KSR.pv.get("$si"))
end

-- Testworthy methods here

return traffic
