--
-- Created by IntelliJ IDEA.
-- User: altanai ( @altanai )
-- Date: 2019-11-14
-- KamailioExmaples
--
-- Kamailio - equivalent of routing blocks in Lua
-- KSR - the new dynamic object exporting Kamailio functions
-- sr - the old static object exporting Kamailio functions
--
-- SIP request routing
-- equivalent of request_route{}
function ksr_request_route()
	KSR.info("===== request - from kamailio lua script\n");
 
	if sr.maxfwd.process_maxfwd(10) < 0 then
		KSR.sl.send_reply(483, "Too Many Hops");
		return;
	end
 
	-- KSR.sl.sreply(200, "OK Lua");
	sr.pv.sets("$du", "sip:127.0.0.1:5080")
	
	KSR.info("set branch , replay , failure blocks \n");
	KSR.tm.t_on_branch("ksr_branch_route_one");
	KSR.tm.t_on_reply("ksr_onreply_route_one");
	KSR.tm.t_on_failure("ksr_failure_route_one");
 
 	KSR.info("relay \n");
	if KSR.tm.t_relay() < 0 then
		KSR.sl.send_reply(500, "Server error")
	end
end
 
-- SIP response routing
-- equivalent of reply_route{}
function ksr_reply_route()
	KSR.info("===== response - from kamailio lua script\n");
end
 
-- branch route callback
-- equivalent of a branch_route{}
function ksr_branch_route_one()
	KSR.info("===== branch route - from kamailio lua script\n");
end
 
-- onreply route callback
-- equivalent of an onreply_route{}
function ksr_onreply_route_one()
	KSR.info("===== onreply route - from kamailio lua script\n");
end
 
-- failure route callback
-- equivalent of a failure_route{}
function ksr_failure_route_one()
	KSR.info("===== failure route - from kamailio lua script\n");
end
