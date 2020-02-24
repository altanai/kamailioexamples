--
-- Created by IntelliJ IDEA.
-- User: altanai ( @altanai )
-- Date: 2019-11-14
-- KamailioExmaples
--

kamailio = require "kamailio"

-- global variables corresponding to defined values (e.g., flags) in kamailio.cfg
FLT_ACC = 1
FLT_ACCMISSED = 2
FLT_ACCFAILED = 3
FLT_NATS = 5

FLB_NATB = 6
FLB_NATSIPPING = 7

-- SIP request routing
-- equivalent of request_route{}
function ksr_request_route()
    kamailio.process_request()
    return 1
end

-- wrapper around tm relay function
function ksr_route_relay()
    -- enable additional event routes for forwarded requests
    -- - serial forking, RTP relaying handling, a.s.o.
    if string.find("INVITE,BYE,SUBSCRIBE,UPDATE", KSR.pv.get("$rm")) then
        if KSR.tm.t_is_set("branch_route") < 0 then
            KSR.tm.t_on_branch("ksr_branch_manage");
        end
    end
    if string.find("INVITE,SUBSCRIBE,UPDATE", KSR.pv.get("$rm")) then
        if KSR.tm.t_is_set("onreply_route") < 0 then
            KSR.tm.t_on_reply("ksr_onreply_manage");
        end
    end

    if KSR.pv.get("$rm") == "INVITE" then
        if KSR.tm.t_is_set("failure_route") < 0 then
            KSR.tm.t_on_failure("ksr_failure_manage");
        end
    end

    if KSR.tm.t_relay() < 0 then
        KSR.sl.sl_reply_error();
    end
    KSR.x.exit();
end

-- RTPProxy control
function ksr_route_natmanage()
    if KSR.siputils.is_request() > 0 then
        if KSR.siputils.has_totag() > 0 then
            if KSR.rr.check_route_param("nat=yes") > 0 then
                KSR.setbflag(FLB_NATB);
            end
        end
    end
    if (not (KSR.isflagset(FLT_NATS) or KSR.isbflagset(FLB_NATB))) then
        return 1;
    end

    KSR.rtpproxy.rtpproxy_manage("co");

    if KSR.siputils.is_request() > 0 then
        if not KSR.siputils.has_totag() then
            if KSR.tmx.t_is_branch_route() > 0 then
                KSR.rr.add_rr_param(";nat=yes");
            end
        end
    end
    if KSR.siputils.is_reply() > 0 then
        if KSR.isbflagset(FLB_NATB) then
            KSR.nathelper.set_contact_alias();
        end
    end
    return 1;
end

-- URI update for dialog requests
function ksr_route_dlguri()
    if not KSR.isdsturiset() then
        KSR.nathelper.handle_ruri_alias();
    end
    return 1;
end

-- Manage outgoing branches
-- equivalent of branch_route[...]{}
function ksr_branch_manage()
    KSR.dbg("new branch [" .. KSR.pv.get("$T_branch_idx") .. "] to " .. KSR.pv.get("$ru") .. "\n");
    ksr_route_natmanage();
    return 1;
end

-- Manage incoming replies
-- equivalent of onreply_route[...]{}
function ksr_onreply_manage()
    KSR.dbg("incoming reply\n");
    local scode = KSR.pv.get("$rs");
    if scode > 100 and scode < 299 then
        ksr_route_natmanage();
    end
    return 1;
end

-- Manage failure routing cases
-- equivalent of failure_route[...]{}
function ksr_failure_manage()
    ksr_route_natmanage();

    if KSR.tm.t_is_canceled() > 0 then
        return 1;
    end
    return 1;
end

-- SIP response handling
-- equivalent of reply_route{}
function ksr_reply_route()
    KSR.info("===== response - from kamailio lua script\n");
    return 1;
end
