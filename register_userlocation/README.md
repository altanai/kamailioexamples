# Kamailio REGISTER and User Location Configuration

This directory contains Kamailio configuration examples for handling SIP REGISTER requests and user location database (USRLOC) management.

## Files

- **kamailio_register_userloc.cfg** - Complete Kamailio configuration for:
  - SIP registration handling
  - User location (USRLOC) storage
  - NAT detection and traversal
  - RTP proxy integration
  - Dialog-based routing

## Key Features

- RFC 3261 compliant REGISTER message handling
- In-memory and SQL database modes for user location storage
- NAT traversal with contact header rewriting
- Loose routing for sequential requests
- Private IP address filtering
- RTP proxy media handling

## Configuration Parameters

- **db_mode** - User location database mode (0=memory, 2=SQL)
- **natping_interval** - NAT keepalive ping interval in seconds
- **nat_bflag** - Flags for NAT detection and marking
- **force_rport** - Add rport parameter for NAT traversal

## Usage

Include this configuration in your main kamailio.cfg or adapt it for your needs.
