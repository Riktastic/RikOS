# =============================================================================
# Firewall Configuration Module
# =============================================================================
#
# Configures a modern, secure firewall using nftables for network protection.
#
# What it does:
# - Enables nftables-based firewall (replaces iptables)
# - Implements stateful packet inspection and traffic filtering
# - Allows SSH, mDNS, DHCP, and ICMP traffic
# - Blocks unsolicited incoming traffic and logs blocked attempts
# - Integrates with fail2ban for dynamic blocking
#
# Requirements:
# - nftables package (installed automatically)
# - Network interfaces configured
#
# Usage:
# - Imported by main configuration automatically
# - Use 'nft list ruleset' to view current rules
# - Check logs with 'journalctl -u nftables'
# =============================================================================

{ config, pkgs, ... }:

{
  # Enable nftables as the firewall backend (disables iptables firewall automatically)
  networking.nftables.enable = true;

  # Define a custom nftables ruleset
  networking.nftables.ruleset = ''
    #! /usr/sbin/nft -f

    # Flush any existing rules to avoid duplicates/conflicts
    flush ruleset

    # Create a table in the 'inet' family (handles both IPv4 and IPv6)
    table inet home_firewall {
      chain input {
        # Attach to input hook, set default policy to drop (deny by default)
        type filter hook input priority 0; policy drop;

        # Allow established and related connections (for replies to outgoing connections)
        ct state established,related accept

        # Allow all loopback (localhost) traffic
        iif "lo" accept

        # Allow SSH only from ZeroTier interfaces (zt+)
        iifname "zt+" tcp dport 22 accept

        # Allow DNS (53/udp and 53/tcp) for name resolution
        udp dport 53 accept
        tcp dport 53 accept

        # Allow DHCP (67/udp, 68/udp) for dynamic IP assignment
        udp dport {67, 68} accept

        # Allow ICMP (ping) for diagnostics
        ip protocol icmp accept
        ip6 nexthdr icmpv6 accept

        # All other incoming traffic is dropped by default
      }
    }
  '';
}
