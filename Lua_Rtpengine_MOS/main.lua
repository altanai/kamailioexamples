--
-- Created by IntelliJ IDEA.
-- User: altanai ( @altanai )
-- Date: 2020-02-24
-- KamailioExmaples
--

FLT_NATS = 1 -- the UAC is behind a NAT , transaction flag
FLB_NATB = 2 -- the UAS is behind a NAT , branch flag
FLT_DIALOG = 4

-- codecs
local rtpengine_codecs_flag = " codec-strip-all codec-offer-PCMA codec-offer-pcma "

local rtpengine_offer_flag = "ICE=remove RTP/AVPF full-rtcp-attribute direction=external direction=external replace-origin replace-session-connection record-call=yes " .. rtpengine_codecs_flag .. " label=caller "
local rtpengine_answer_flag = "ICE=remove RTP/AVPF full-rtcp-attribute direction=external direction=external replace-origin replace-session-connection record-call=yes label=callee "


--[[--------------------------------------------------------------------------
------------------------- Request Routing Logic --------------------------]]
function ksr_request_route()
    local request_method = KSR.pv.get("$rm") or "";
    local user_agent = KSR.pv.get("$ua") or "";

    KSR.log("info", " KSR_request_route request, method " .. request_method .. " user_agent " .. user_agent .. "\n");

    -- per request initial checks
    ksr_route_reqinit(user_agent);

    -- OPTIONS processing
    ksr_route_options_process(request_method);

    -- NAT detection
    ksr_route_natdetect();

    -- CANCEL processing
    ksr_route_cancel_process(request_method);

    -- handle requests within SIP dialogs
    ksr_route_withindlg(request_method);

    -- handle retransmissions
    ksr_route_retrans_process();

    -- handle request without to tag
    ksr_route_request_process(request_method);
    return 1;
end

--[[--------------------------------------------------------------------------
-- Per SIP request initial checks
-------------------------------------------------------------------------]]
function ksr_route_reqinit(user_agent)

    -- Max forwards Check
    local max_forward = 10
    local maxfwd_check = KSR.maxfwd.process_maxfwd(max_forward)
    if maxfwd_check < 0 then
        KSR.log("err", "too many hops sending 483")
        KSR.sl.sl_send_reply(483, "Too Many Hops")
        KSR.x.exit()
    end

    -- sanity Check
    local sanity_check = KSR.sanity.sanity_check(1511, 7)
    if sanity_check < 0 then
        KSR.log("err", "received invalid sip packet \n")
        KSR.x.exit()
    end

    KSR.log("info", "initial request check is passed \n")
    return 1
end

--[[--------------------------------------------------------------------
-- CANCEL Processing
-- if transaction exists relay CANCEL request, else exit quitely
--------------------------------------------------------------------]]
function ksr_route_cancel_process(request_method)
    if request_method == "CANCEL" then
        KSR.log("info", "sip cancel request received \n");
        if KSR.tm.t_check_trans() > 0 then
            ksr_route_relay(request_method)
        end
        KSR.x.exit()
    end
    return 1;
end

--[[--------------------------------------------------------------------------
-- OPTIONS Processing sending keepalive 200
------------------------------------------------------------------------------]]
function ksr_route_options_process(request_method)
    if request_method == "OPTIONS"
            and KSR.is_myself(KSR.pv.get("$ru"))
            and KSR.pv.is_null("$rU") then
        KSR.log("info", "sending keepalive response 200 \n")
        KSR.sl.sl_send_reply(200, "Keepalive")
        KSR.x.exit()
    end
    return 1
end

--[[--------------------------------------------------------------------------
    Name: ksr_route_request_process()
    Desc: -- route all requests
    if req not INVITE then it will reject the request with 501 , else create the transaction
-----------------------------------------------------------------------------]]
function ksr_route_request_process(request_method)

    --remove pre loaded request route headers
    KSR.hdr.remove("Route");

    if request_method ~= "INVITE" then
        KSR.log("err", "method not allowed, sending 501 \n");
        KSR.sl.sl_send_reply(501, "Method is not implemented");

    else
        KSR.rr.record_route()
        local dest_number = KSR.pv.get("$rU")
        local to_uri = KSR.pv.get("$tu");
        local call_id = KSR.pv.get("$ci")
        local from_number = KSR.pv.get("$fU") or ""
        KSR.setflag(FLT_DIALOG);
        KSR.pv.sets("$avp(dest_number)", dest_number)
        KSR.pv.sets("$avp(to_uri)", to_uri);
        KSR.pv.sets("$avp(from_number)", from_number);
        KSR.pv.sets("$avp(call_id)", call_id);

        KSR.tm.t_newtran()
        KSR.log("info", "transaction created for call \n");

        -- can call evapi or any other async process
        KSR.tmx.t_suspend()
        local id_index = KSR.pv.get("$T(id_index)")
        local id_label = KSR.pv.get("$T(id_label)")
        KSR.tmx.t_continue(id_index, id_label, "service_callback")
    end
    KSR.x.exit()
end

--[[--------------------------------------------------------------------------
   Name: ksr_route_retrans_process()
   Desc: -- Retransmission Process
------------------------------------------------------------------------------]]
function ksr_route_retrans_process()
    -- handle retransmissions

    -- check if request is handled by another process
    if KSR.tmx.t_precheck_trans() > 0 then
        KSR.log("info", "retransmission request received \n");
        -- for non-ack and cancel used to send resends the last reply for that transaction
        KSR.tm.t_check_trans()
        KSR.x.exit()
    end

    -- check for acive transactions
    if KSR.tm.t_check_trans() == 0 then
        KSR.log("info", "no active transaction for this request \n");
        KSR.x.exit()
    end
end

--[[--------------------------------------------------------------------------
   Name: ksr_route_withindlg()
   Desc: -- Handle requests within SIP dialogs
------------------------------------------------------------------------------]]

function ksr_route_withindlg(request_method)

    -- return if not a dialog equest , can be checked by missing to tag
    if KSR.siputils.has_totag() < 0 then
        return 1
    end

    -- return if not a known dialog equest
    if KSR.dialog.is_known_dlg() < 0 then
        return 1
    end

    KSR.log("info", "received a request " .. request_method .. " in dialog \n");
    KSR.rr.record_route()

    -- sequential request withing a dialog should take the path determined by record-routing
    if request_method == "BYE" then
        KSR.pv.sets("$dlg_var(bye_rcvd)", "true")

        --        KSR.log("info", ">>> Add stats header")
        --        KSR.hdr.append("X-RTP-Statistics: " .. KSR.pv.get("$avp(rtpstat)") .. "\r\n")

        KSR.log("info", ">>> Set leg label")
        KSR.pv.sets("$avp(mos_A_label)", "caller");
        KSR.pv.sets("$avp(mos_B_label)", "callee");

        KSR.log("info", ">>> delete RTPengine \n ")
        -- KSR.rtpengine.rtpengine_query("label=mos_A_label")
        -- KSR.log("info", "mos_average_A_pv " .. KSR.pv.getvn("$avp(mos_A_label)", 0) .. "\n ")

        KSR.rtpengine.rtpengine_delete0()

        KSR.log("info", " mos avg " .. KSR.pv.getvn("$avp(mos_average)", 0) .. "\n ")
        KSR.log("info", " mos max " .. KSR.pv.getvn("$avp(mos_max)", 0) .. "\n ")
        KSR.log("info", " mos min " .. KSR.pv.getvn("$avp(mos_min)", 0) .. "\n ")

        KSR.log("info", "mos_average_packetloss_pv" .. KSR.pv.getvn("$avp(mos_average_packetloss)",0).. "\n ")
        KSR.log("info", "mos_average_jitter_pv" .. KSR.pv.getvn("$avp(mos_average_jitter)",0).. "\n ")
        KSR.log("info", "mos_average_roundtrip_pv" .. KSR.pv.getvn("$avp(mos_average_roundtrip)",0).. "\n ")
        KSR.log("info", "mos_average_samples_pv" .. KSR.pv.getvn("$avp(mos_average_samples)",0).. "\n ")

        KSR.log("info", "mos_min_pv" .. KSR.pv.getvn("$avp(mos_min)",0).. "\n ")
        KSR.log("info", "mos_min_at_pv" .. KSR.pv.getvn("$avp(mos_min_at)",0).. "\n ")
        KSR.log("info", "mos_min_packetloss_pv" .. KSR.pv.getvn("$avp(mos_min_packetloss)",0).. "\n ")
        KSR.log("info", "mos_min_jitter_pv" .. KSR.pv.getvn("$avp(mos_min_jitter)",0).. "\n ")
        KSR.log("info", "mos_min_roundtrip_pv" .. KSR.pv.getvn("$avp(mos_min_roundtrip)",0).. "\n ")

        KSR.log("info", "mos_A_label_pv " .. KSR.pv.getvn("$avp(mos_A_label)", 1) .. "\n ")
        KSR.log("info", "mos_average_packetloss_A_pv " .. KSR.pv.getvn("$avp(mos_average_packetloss_A)", 0) .. "\n ")
        KSR.log("info", "mos_average_jitter_A_pv " .. KSR.pv.getvn("$avp(mos_average_jitter_A)", 0) .. "\n ")
        KSR.log("info", "mos_average_roundtrip_A_pv " .. KSR.pv.getvn("$avp(mos_average_roundtrip_A)", 0) .. "\n ")
        KSR.log("info", "mos_average_A_pv " .. KSR.pv.getvn("$avp(mos_A_label)", 0) .. "\n ")

        KSR.log("info", "mos_B_label_pv " .. KSR.pv.getvn("$avp(mos_B_label)",1) .. "\n ")
        KSR.log("info", "mos_average_packetloss_B_pv " .. KSR.pv.getvn("$avp(mos_average_packetloss_B)", 0) .. "\n ")
        KSR.log("info", "mos_average_jitter_B_pv " .. KSR.pv.getvn("$avp(mos_average_jitter_B)", 0) .. "\n ")
        KSR.log("info", "mos_average_roundtrip_B_pv " .. KSR.pv.getvn("$avp(mos_average_roundtrip_B)", 0) .. "\n ")
        KSR.log("info", "mos_average_B_pv " .. KSR.pv.getvn("$avp(mos_average_B)", 0) .. "\n ")
    end

    if request_method == "INVITE" or request_method == "UPDATE" or request_method == "BYE" then
        if KSR.rr.is_direction("downstream") then
            KSR.log("info", " downstream  \n");
        else
            -- interchange to and from uri for upstream request
            KSR.log("info", " upstream  \n");
            local to_uri = KSR.pv.get("$dlg_var(to_uri)") or KSR.pv.get("$avp(to_uri)")
            KSR.pv.sets("$fu", to_uri);
        end
    end

    -- if loose_route just relay , if ACK then NATmanage and relay
    local routeresults = {
        [1] = "route calculation has been successful",
        [2] = "route calculation based on flow-token has been successful",
        [-1] = " route calculation has been unsuccessful",
        [-2] = "outbound flow-token shows evidence of tampering",
        [-3] = "next hop is taken from a preloaded route set"
    }
    local routerresult = KSR.rr.loose_route()
    for key, value in pairs(routeresults) do
        if routerresult == key then
            KSR.log("info", " loose_route result - " .. key .. " " .. value .. "\n")
        end
    end

    if routerresult > 0 then
        KSR.log("info", "in-dialog request,loose_route \n");
        ksr_route_dlguri();
        if request_method == "ACK" then
            ksr_route_natmanage();
        end
        ksr_route_relay(request_method);
        KSR.x.exit()
    end

    -- if not loose_route just relay , check for ACK
    -- Relay ACK if it matches with a transaction. Else ignore and discard
    KSR.log("info", "in-dialog request,not loose_route \n")
    if request_method == "ACK" then
        if KSR.tm.t_check_trans() > 0 then
            -- no loose-route, but stateful ACK; must be an ACK after a 487 or e.g. 404 from upstream server
            KSR.log("info", "in-dialog request,not loose_route with transaction - relaying \n")
            ksr_route_relay(request_method);
        end
        KSR.log("err", "in-dialog request,not loose_route without transaction, exit \n")
        KSR.x.exit()
    end

    KSR.log("err", "received invalid sip packet,sending 404 \n");
    KSR.sl.sl_send_reply(404, "Not here");
    KSR.x.exit()
end

--[[--------------------------------------------------------------------------
   Name: ksr_route_dlguri()
   Desc: -- URI update for dialog requests
------------------------------------------------------------------------------]]
function ksr_route_dlguri()
    KSR.log("info", "ksr_route_dlguri \n")
    if not KSR.isdsturiset() then
        KSR.log("info", "not isdsturiset then handle_ruri_alias \n")
        KSR.nathelper.handle_ruri_alias()
    end
    return 1
end

--[[--------------------------------------------------------------------------
   Name: ksr_route_relay()
   Desc: adding the reply_route,failure_route,branch_route to request. relay the request.
------------------------------------------------------------------------------]]

function ksr_route_relay(req_method)
    local request_uri = KSR.pv.get("$ru") or ""
    local dest_uri = KSR.pv.get("$du") or ""
    KSR.log("info", "relaying the message with request uri - " .. request_uri .. " destination uri - " .. dest_uri .. "\n");

    local bye_rcvd = KSR.pv.get("$dlg_var(bye_rcvd)") or "false";

    if req_method == "BYE" then
        if KSR.tm.t_is_set("branch_route") < 0 then
            KSR.tm.t_on_branch("ksr_branch_manage");
        end

    elseif req_method == "INVITE" or req_method == "UPDATE" then
        if KSR.tm.t_is_set("branch_route") < 0 then
            KSR.tm.t_on_branch("ksr_branch_manage")
        end

        if KSR.tm.t_is_set("onreply_route") < 0 then
            KSR.tm.t_on_reply("ksr_onreply_manage_offer")
        end

        if KSR.tm.t_is_set("failure_route") < 0 and req_method == "INVITE" then
            KSR.tm.t_on_failure("ksr_failure_manage")
        end

        if bye_rcvd ~= "true" and KSR.textops.has_body_type("application/sdp") > 0 then
            KSR.log("info", "method contains sdp, creating offer to rtpengine \n")

            if KSR.rtpengine.rtpengine_offer(rtpengine_offer_flag) > 0 then
                KSR.log("info", "received success reply for rtpengine offer \n")
            else
                KSR.log("err", "received failure reply for rtpengine offer \n")
            end
            KSR.tm.t_on_reply("ksr_onreply_manage_answer");
        end

    elseif req_method == "ACK" then
        if bye_rcvd ~= "true" and KSR.textops.has_body_type("application/sdp") > 0 then
            KSR.log("info", "request contains sdp, sending answer command to rtpengine \n")
            KSR.rtpengine.rtpengine_answer()
        end
    end
    KSR.tm.t_relay()
    KSR.x.exit()
end


--[[--------------------------------------------------------------------------
   Name: ksr_route_natdetect()
   Desc: caller NAT detection and add contact alias
------------------------------------------------------------------------------]]
function ksr_route_natdetect()
    KSR.log("info", "ksr_route_natdetect - force rport \n")
    KSR.force_rport()
    if KSR.nathelper.nat_uac_test(19) > 0 then
        KSR.log("info", "request is behind nat \n")

        if KSR.siputils.is_first_hop() > 0 then
            KSR.log("info", "adding contact alias \n")
            KSR.nathelper.set_contact_alias()
        end
        KSR.setflag(FLT_NATS);
    end
    return 1
end

--[[--------------------------------------------------------------------------
   Name: ksr_route_natmanage()
   Desc: managing the sip-response and sip-request behind the nat
------------------------------------------------------------------------------]]
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

    if KSR.siputils.is_request() > 0 then
        if not KSR.siputils.has_totag() then
            if KSR.tmx.t_is_branch_route() > 0 then
                KSR.rr.add_rr_param(";nat=yes")
            end
        end
    elseif KSR.siputils.is_reply() > 0 then
        if KSR.isbflagset(FLB_NATB) then
            KSR.nathelper.set_contact_alias()
        end
    end
    return 1;
end

--[[--------------------------------------------------------------------------
   Name: ksr_branch_manage()
   Desc: managing outgoing branch
------------------------------------------------------------------------------]]
function ksr_branch_manage()
    KSR.log("dbg", "new branch [" .. KSR.pv.get("$T_branch_idx") .. "] to " .. KSR.pv.get("$ru") .. "\n");
    ksr_route_natmanage();
    return 1;
end

--[[--------------------------------------------------------------------------
   Name: ksr_onreply_manage()
   Desc: managing incoming response for the request
------------------------------------------------------------------------------]]
function ksr_onreply_manage()
    local response_code = KSR.pv.get("$rs")
    KSR.log("info", "incoming reply with response code " .. tostring(response_code) .. "\n");
    local current_time = KSR.pv.get("$TS")

    local is_downstream = KSR.pv.get("$avp(is_downstream)") or "false";
    if is_downstream == "true" then
        local to_uri = KSR.pv.get("$dlg_var(to_uri)") or KSR.pv.get("$avp(to_uri)")
        KSR.pv.sets("$tu", to_uri);
    end

    if response_code > 100 and response_code < 299 then
        if response_code == 180 or response_code == 183 then
            KSR.log("info", "incoming call_ring_time" .. current_time .. "\n")
        elseif response_code == 200 then
            KSR.log("info", "incoming call_answer_time" .. current_time .. "\n")
        end
        ksr_route_natmanage();
    end
    return 1;
end

--[[--------------------------------------------------------------------------
   Name: ksr_onreply_manage_answer()
   Desc: managing incoming response for the request and sending answer command to
   rtpengine
------------------------------------------------------------------------------]]

function ksr_onreply_manage_answer()
    local bye_rcvd = KSR.pv.get("$dlg_var(bye_rcvd)") or "false";
    if bye_rcvd ~= "true" and KSR.textops.has_body_type("application/sdp") > 0 then
        KSR.log("info", "response contains sdp, answer to rtpengine \n")

        if KSR.rtpengine.rtpengine_answer(rtpengine_answer_flag) > 0 then
            KSR.log("info", "received success reply for rtpengine answer from instance \n")
        else
            KSR.log("err", "received failure reply for rtpengine answer from instance \n")
        end
    end
    ksr_onreply_manage()
    return 1;
end


--[[--------------------------------------------------------------------------
   Name: ksr_onreply_manage_offer()
   Desc: managing incoming response for the request and sending offer command to
   rtpengine
------------------------------------------------------------------------------]]

function ksr_onreply_manage_offer()
    local bye_rcvd = KSR.pv.get("$dlg_var(bye_rcvd)") or "false";
    if bye_rcvd ~= "true" and KSR.textops.has_body_type("application/sdp") > 0 then
        KSR.log("info", "response contains sdp, offer to rtpengine \n")
        KSR.rtpengine.rtpengine_offer()
    end
    ksr_onreply_manage()
    return 1;
end

-- manage  failure response 3xx,4xx,5xx
---------------------------------------------
function ksr_failure_manage()
    local response_code = KSR.pv.get("$T(reply_code)")
    local reply_type = KSR.pv.get("$T(reply_type)")
    local reason_phrase = KSR.pv.get("$T_reply_reason")
    local request_method = KSR.pv.get("$rm");
    KSR.log("err", "failure route: " .. request_method .. " incoming reply received - " ..
            tostring(response_code) .. tostring(reply_type) .. tostring(reason_phrase) .. "\n")

    -- send delet command to rtpengine based on callid
    KSR.log("info", "failure route: sending delete command to rtpengine \n")
    KSR.rtpengine.rtpengine_delete0()

    -- check trsansaction state and drop if cancelled
    if KSR.tm.t_is_canceled() == 1 then
        KSR.x.exit()
    end

    -- KSR.tm.t_set_disable_internal_reply(1)
    KSR.sl.send_reply(503, "Service Unavailable")
    KSR.x.exit()
end

--[[--------------------------------------------------------------------------
   Name: ksr_htable_event(evname)
   Desc: callback for the given htable event-name
------------------------------------------------------------------------------]]

function ksr_htable_event(evname)
    KSR.log("info", "htable module triggered event - " .. evname .. "\n");
    return 1;
end

--[[--------------------------------------------------------------------------
   Name: ksr_dialog_event(evname)
   Desc: get the dispatch domain from the dispatcher list based on policy
------------------------------------------------------------------------------]]

function ksr_dialog_event(evname)
    if (evname == "dialog:end") or (evname == "dialog:failed") then

        local call_id = KSR.pv.get("$ci")
        if not call_id then
            KSR.log("info", "no callid for this call")
        end
    end
end


--[[--------------------------------------------------------------------------
   Name: ksr_xhttp_event(evname)
   Desc: http request and response handling
------------------------------------------------------------------------------]]

function ksr_xhttp_event(evname)
    local rpc_method = KSR.pv.get("$rm") or ""
    if ((rpc_method == "POST" or rpc_method == "GET")) then
        if KSR.xmlrpc.dispatch_rpc() < 0 then
            KSR.log("err", "error while executing xmlrpc event" .. "\n")
        end
    end
    return 1
end

function service_callback()
    local dispatch_set = 1
    local routing_policy = 8
    -- selects a destination from addresses set and rewrites the host and port from R-URI.
    if KSR.dispatcher.ds_select_dst(dispatch_set, routing_policy) > 0 then
        KSR.log("info", "request-uri - " .. tostring(KSR.pv.get("$ru")) .. "\n")
        local request_method = KSR.pv.get("$rm") or "";
        ksr_route_relay(request_method);
    else
        KSR.log("err", "dispatcher lookup failed" .. "\n")
        KSR.x.exit()
    end
end

