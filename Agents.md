# Kamailio Agents & User Agents

## Overview

In the context of Kamailio and SIP, an **Agent** typically refers to a SIP User Agent (UA) or an automated entity that can initiate, receive, or control SIP communication. This document describes the various types of agents and how they interact with Kamailio configurations in this repository.

## Types of Agents

### 1. SIP User Agents (UA)
**Definition:** SIP endpoints that can both send and receive SIP requests and responses.

**Examples:**
- SIP phones (Grandstream, Cisco, Polycom)
- Softphones (Zoiper, Linphone, X-Lite)
- VoIP applications (Jami/GNU Ring, Twilio, etc.)
- WebRTC clients (browser-based)
- IoT devices (SIP doorbells, intercoms)

**Typical SIP Methods Used:**
```
REGISTER   - Register with Kamailio (location service)
INVITE     - Initiate a call
BYE        - Terminate a call
CANCEL     - Cancel pending INVITE
UPDATE     - Update session without reinviting
INFO       - Send DTMF or other info
MESSAGE    - Send instant messages
SUBSCRIBE  - Subscribe to events
NOTIFY     - Notify subscribers of events
```

### 2. B2BUA (Back-to-Back User Agent)
**Definition:** An entity that acts as both a UA and a server, maintaining two independent SIP dialogs.

**Use Cases in This Repository:**
- [Loadbalancer_SIP_proxy](Loadbalancer_SIP_proxy/) - Distributes calls to multiple agents
- [edge_proxy](edge_proxy/) - Acts as gateway between domains
- [Lua_load_balancer](Lua_load_balancer/) - Load balances across agents

### 3. Call Center Agents
**Definition:** Software agents handling incoming customer calls with specific state management.

**Features:**
- Call queuing and distribution
- Agent state management (available, busy, logged out)
- Call recording and monitoring
- Skill-based routing
- IVR interaction

**Related Examples:**
- [accounting](accounting/) - Call tracking and billing
- [mos_cdr_accmodule](mos_cdr_accmodule/) - Quality metrics per agent
- [forking](forking/) - Distribute calls to multiple agents

### 4. AI/Bot Agents
**Definition:** Automated agents that handle SIP communication using AI/ML without direct human intervention.

**Capabilities:**
- Automated call answering
- IVR and voice response
- Call routing based on intent
- Sentiment analysis
- Call transcription and analysis
- DTMF handling

**Technologies:**
- Text-to-Speech (TTS) for voice responses
- Speech-to-Text (STT) for call analysis
- Natural Language Processing (NLP) for intent detection
- Machine Learning for call routing

## Agent Configuration in Kamailio

### Registration Process

Agents register with Kamailio using the REGISTER method:

```
Agent → Kamailio: REGISTER sip:domain.com

Kamailio → Agent: 100 Trying
Kamailio → Agent: 200 OK (stores location in USRLOC)
```

**Related Examples:**
- [register_and_userlocation](register_and_userlocation/) - Basic registration
- [Lua_Registrar_permission_auth](Lua_Registrar_permission_auth/) - Auth-based registration

### Call Routing to Agents

#### Static Routing
Direct routing to known agent addresses:
```
sip:agent1@domain.com
sip:agent2@domain.com
```

#### Dynamic Routing (USRLOC-based)
Kamailio looks up agent location from registration database:
```
lookup("location") - Find registered agent endpoints
```

**Related Examples:**
- [stateful_dialog_handle](stateful_dialog_handle/) - Dialog-aware routing
- [forking](forking/) - Parallel/serial routing to multiple agents

#### Intelligent Routing
Based on custom logic:
- Load (current call count per agent)
- Availability (agent state)
- Skills (agent capabilities)
- Location (geographic routing)

**Related Examples:**
- [Lua_load_balancer](Lua_load_balancer/) - Lua-based intelligent routing
- [Lua_sbc_with_auth](Lua_sbc_with_auth/) - SBC with agent authentication

### NAT Handling for Agents

Agents often operate behind NAT. Kamailio must detect and handle this:

```
NAT Detection:
- Check if source IP != Via header IP
- Check if Contact header has private IP
- Perform NAT tests

Response:
- Rewrite Contact header with source IP
- Add rport parameter to Via
- Force RTP proxy for media
```

**Related Examples:**
- [nat](nat/) - Basic NAT handling
- [Lua_Nat_handle](Lua_Nat_handle/) - Lua-based NAT traversal
- [RTPEngine_media_proxy](RTPEngine_media_proxy/) - Media NAT handling

### Media Handling for Agents

Kamailio can proxy RTP media between agents:

```
Agent1 → Kamailio → Agent2
(SIP)   (proxy)    (SIP)
  ↓                 ↓
 RTP1  ← Media →   RTP2
```

**Related Examples:**
- [RTPProxy](RTPProxy/) - Legacy RTP proxying
- [RTPEngine_media_proxy](RTPEngine_media_proxy/) - Modern RTP media handling
- [webrtc_to_sip_with_rtpengine](webrtc_to_sip_with_rtpengine/) - WebRTC agent support

## Agent-Related Configuration Examples

### Example 1: Simple Agent Registration & Routing

```lua
-- Register agent
if method == "REGISTER" then
    save("location")
    exit
end

-- Route call to agent
if method == "INVITE" then
    lookup("location")  -- Find agent location
    t_relay()
end
```

**Full Example:** [register_and_userlocation](register_and_userlocation/kamailio_register_userloc.cfg)

### Example 2: Multiple Agent Load Balancing

```lua
local agents = {
    "sip:agent1@10.0.0.1:5060",
    "sip:agent2@10.0.0.2:5060",
    "sip:agent3@10.0.0.3:5060"
}

-- Route to least loaded agent
local agent = find_least_loaded_agent(agents)
route_to_uri(agent)
```

**Full Example:** [Lua_load_balancer](Lua_load_balancer/loadbalancer.lua)

### Example 3: NAT-Aware Agent Handling

```cfg
# Detect if agent is behind NAT
if (nat_uac_test("3")) {
    fix_nated_contact()      # Rewrite Contact header
    force_rtp_proxy()        # Force RTP through proxy
    setflag(6)               # Mark as NATed
}
```

**Full Example:** [Lua_Nat_handle](Lua_Nat_handle/kamailionat.lua)

### Example 4: Agent Authentication & Authorization

```lua
-- Check agent credentials
if not auth_check(domain, "subscriber", 1) then
    auth_challenge(domain, 0)
    return
end

-- Log agent in
save("location")
```

**Full Example:** [Lua_Registrar_permission_auth](Lua_Registrar_permission_auth/kamailio-basic-kemi-lua.lua)

### Example 5: Call Recording for Agents

```cfg
# Record agent calls
if (method == "INVITE") {
    record_call($ru, "/var/spool/calls/" + $ci + ".wav")
}
```

**Full Example:** [accounting](accounting/kamailio-advanced.cfg)

## Agent State Management

### Agent States in Call Center

```
┌─────────────┐
│   Offline   │
└─────┬───────┘
      │ Login
      ▼
┌─────────────┐
│ Available   │◄─────────┐
└─────┬───────┘          │
      │ Call received    │ Call ended/released
      ▼                  │
┌─────────────┐          │
│   Busy      │──────────┘
└─────┬───────┘
      │ Go unavailable
      ▼
┌─────────────┐
│ Unavailable │◄─────────┐
└─────┬───────┘          │
      │ Available again  │
      └──────────────────┘
```

### Implementation Approaches

1. **In-Memory State** - Fast but not persistent
   ```lua
   agent_state[agent_id] = "available"
   ```

2. **Database State** - Persistent and scalable
   ```lua
   query = "UPDATE agents SET state='busy' WHERE id=" .. agent_id
   ```

3. **Distributed State** - For clustered Kamailio
   ```lua
   redis:set("agent:" .. agent_id, "busy")
   ```

**Related Examples:**
- [redis_db](redis_db/) - Redis state management
- [psql_location_storage](psql_location_storage/) - PostgreSQL persistence

## Agent Interaction Patterns

### Pattern 1: Direct Agent Call

```
Caller → Kamailio → Agent
         (routing)

1. REGISTER agent with Kamailio
2. Caller sends INVITE to Kamailio
3. Kamailio routes INVITE to agent
4. Agent answers (200 OK)
5. RTP media flows between caller and agent
6. Agent sends BYE to end call
```

**Examples:** [Barebone_SIPServer](Barebone_SIPServer/), [register_and_userlocation](register_and_userlocation/)

### Pattern 2: IVR → Agent Routing

```
Caller → Kamailio → IVR → Kamailio → Agent
                  (menu)           (routing)

1. Caller enters IVR
2. Caller selects department (DTMF)
3. IVR transfers to appropriate agent
4. Agent picks up call
```

**Examples:** [early_media_handle](early_media_handle/), [forking](forking/)

### Pattern 3: Call Center Queue

```
Caller → Kamailio → Queue → Wait → Agent
                          (IVR)
```

### Pattern 4: Agent Failover

```
Caller → Kamailio → Agent1 (busy) → Agent2 (busy) → Voicemail
              (forking/routing)
```

**Examples:** [forking](forking/), [Lua_load_balancer](Lua_load_balancer/)

### Pattern 5: Blended Agent (Voice + Digital)

```
Customer → Multiple Channels
         ├─ Voice (SIP)
         ├─ Chat (XMPP/WebSocket)
         └─ Email (SMTP)
              ↓
           Agent Platform
```

## Security Considerations for Agents

### 1. Authentication
- **Method:** SIP Digest Authentication or Certificates
- **Example:** [Lua_Registrar_permission_auth](Lua_Registrar_permission_auth/)

### 2. Encryption
- **Transport:** TLS (SIPS)
- **Media:** SRTP (Secure RTP)
- **Example:** [TLSonly](TLSonly/)

### 3. Authorization
- Verify agent is allowed to handle calls for their domain
- Check agent permissions/skills
- Enforce rate limits per agent

**Example:** [Lua_sbc_with_auth](Lua_sbc_with_auth/)

### 4. Call Recording & Privacy
- Notify agents when calls are recorded
- Comply with local regulations
- Securely store recordings

**Example:** [mos_cdr_accmodule](mos_cdr_accmodule/)

## Agent Monitoring & Quality Metrics

### Key Metrics

| Metric | Purpose |
|--------|---------|
| **ASA** (Average Speed of Answer) | How quickly agents answer calls |
| **AHT** (Average Handle Time) | Total time agent spends per call |
| **ACW** (After Call Work) | Time for agent to complete post-call tasks |
| **MOS** (Mean Opinion Score) | Audio quality score (0-5) |
| **Call Duration** | Total call length |
| **Agent Utilization** | % of time agent is on calls |

### Implementation
- Track metrics via accounting module
- Store in database (MySQL, PostgreSQL)
- Calculate MOS from RTP statistics

**Examples:**
- [mos_cdr_accmodule](mos_cdr_accmodule/) - MOS with CDR
- [mos_rtpstats_rtpengine](mos_rtpstats_rtpengine/) - RTP-based MOS
- [accounting](accounting/) - Call metrics

## Agent Testing

### SIPp for Agent Testing
SIPp is a tool to simulate agents and test Kamailio:

```bash
# Simulate 10 agents registering
sipp -sf register.xml -l 10 kamailio.example.com

# Simulate incoming calls
sipp -sf uac.xml kamailio.example.com

# Stress test with 100 concurrent calls
sipp -sf invite.xml -l 100 kamailio.example.com
```

**Example SIPp Scenarios:** [sipp](sipp/)

## Best Practices

1. **Agent Authentication**
   - Always require authentication for agent registration
   - Use strong passwords or certificates

2. **NAT Awareness**
   - Detect and handle agents behind NAT
   - Use RTP proxy for media relay

3. **State Management**
   - Track agent availability/state persistently
   - Use database for multi-server deployments

4. **Load Balancing**
   - Distribute calls evenly across agents
   - Consider agent skill sets and load

5. **Media Quality**
   - Monitor and log RTP quality metrics
   - Implement codec negotiation properly

6. **Failover & Redundancy**
   - Route to backup agents if primary unavailable
   - Implement call queuing for high load

7. **Monitoring & Analytics**
   - Log all agent interactions
   - Track quality metrics (MOS, ASA, AHT)
   - Alert on anomalies

## Related Documentation

- [RFC 3261 - SIP Protocol](https://tools.ietf.org/html/rfc3261)
- [RFC 3324 - Private Identities in SIP](https://tools.ietf.org/html/rfc3324)
- [RFC 4579 - SIP Call Control and Media Server](https://tools.ietf.org/html/rfc4579)
- [Kamailio Official Documentation](https://kamailio.org/docs/)
- [SIPp Testing Tool](https://sipp.sourceforge.net/)

## See Also

- [README.md](README.md) - Main repository overview
- Individual example directories for specific agent configurations
