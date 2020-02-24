core = require "kamailio.core"

local reply = {}

function reply.stateless(cause, reason)
    if cause == nil then
        KSR.err("Can't send stateless response w/o cause!")
        return false
    end
    reason = reason or "Unknown"
    KSR.sl.sl_send_reply(cause, reason)
end

function reply.stateful(cause, reason)
    if cause == nil then
        KSR.err("Can't send stateless response w/o cause!")
        return false
    end
    reason = reason or "Unknown"
    KSR.tm.t_reply(cause, reason)
end

function reply.with_stateless_error_and_exit()
    KSR.sl.sl_reply_error()
    core.exit()
end

function reply.with_stateless_200_and_exit()
    reply.stateless(200, "OK")
    core.exit()
end

function reply.with_stateless_403_and_exit()
    reply.stateless(403, "Forbidden")
    core.exit()
end

function reply.with_stateless_404_and_exit()
    reply.stateless(404, "Not Here")
    core.exit()
end

function reply.with_stateless_405_and_exit()
    reply.stateless(405, "Method Not Allowed")
    core.exit()
end

function reply.with_stateless_484_and_exit()
    reply.stateless(484, "Address Incomplete")
    core.exit()
end

function reply.with_stateful_404_and_exit()
    reply.stateful(404, "Not Found")
    core.exit()
end



return reply