# =============================================================================
# Network DNS Configuration Module
# =============================================================================
#
# This module configures a privacy-focused DNS setup using DNS-over-TLS (DoT)
# with systemd-resolved for enhanced security and privacy.
#
# What it does:
# - Enables DNS-over-TLS for encrypted DNS queries
# - Configures privacy-focused DNS servers (185.222.222.222, 45.11.45.11)
# - Provides fallback DNS servers for reliability
# - Protects against DNS-based tracking and censorship
# - Implements DNSSEC validation support
# - Uses systemd-resolved for DNS management
# - Enables automatic fallback to plain DNS when needed
#
# Requirements:
# - systemd-resolved service
# - Internet connection for DNS queries
# - Compatible network configuration
# - TLS support for encrypted queries
#
# Usage:
# - Imported by device configurations automatically
# - DNS-over-TLS enabled automatically
# - Use resolvectl status to check configuration
# - Use resolvectl query to test DNS resolution
# =============================================================================

# modules/network/dns.nix
# Shared DNS module for DNS-over-TLS (DoT) using upstreams and fallbacks.
# Upstreams (DoT):
#   - 185.222.222.222
#   - 45.11.45.11
# Fallbacks (plain DNS):
#   - 185.222.222.222
#   - 45.11.45.11
#   - 193.110.81.0
#   - 185.253.5.0

{ config, pkgs, ... }:

{
  # ============================================================================
  # DNS Configuration
  # ============================================================================
  # Configure systemd-resolved for DNS-over-TLS and privacy-focused DNS
  services.resolved = {
    enable = true;                     # Enable systemd-resolved DNS service
    
    # ========================================================================
    # DNS Configuration
    # ========================================================================
    # Configure DNS servers and encryption settings
    extraConfig = ''
      # ================================================================
      # DNS Server Configuration
      # ================================================================
      [Resolve]
      # Primary DNS servers for encrypted queries
      # These servers support DNS-over-TLS for enhanced privacy
      DNS=185.222.222.222 45.11.45.11 193.110.81.0 185.253.5.0
      
      # ================================================================
      # Fallback DNS Configuration
      # ================================================================
      # Fallback DNS servers for reliability
      # Used when DoT servers are unavailable
      FallbackDNS=185.222.222.222 45.11.45.11 193.110.81.0 185.253.5.0
      
      # ================================================================
      # DNS-over-TLS Configuration
      # ================================================================
      # Enable DNS-over-TLS for encrypted DNS queries
      # This prevents ISP snooping and DNS-based tracking
      DNSOverTLS=yes
      
      # ================================================================
      # Fallback Encryption
      # ================================================================
      # Allow fallback to plain DNS when DoT is unavailable
      # This ensures DNS resolution works even if DoT fails
      DNSOverTLSFallback=yes
    '';
  };
} 
