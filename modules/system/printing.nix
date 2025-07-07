# =============================================================================
# System Printing Configuration Module
# =============================================================================
#
# Configures CUPS printing system and Avahi printer discovery for comprehensive printing support.
#
# What it does:
# - Enables CUPS (Common Unix Printing System) for printing infrastructure
# - Configures Avahi for network printer discovery and zero-configuration networking
# - Provides local and network printing capabilities
# - Enables web-based printer administration at http://localhost:631
# - Supports automatic printer discovery and management
# - Includes print job queuing and printer driver management
# - Disabled in server mode to reduce resource usage
#
# Requirements:
# - CUPS package and dependencies
# - Avahi package for network discovery
# - Compatible printer hardware
# - Network connectivity for network printers
# - Desktop mode (disabled in server mode)
#
# Usage:
# - Import in device configurations
# - CUPS starts automatically on boot (desktop mode only)
# - Web interface available at http://localhost:631 (desktop mode only)
# - Use lpstat, lpq, lp commands for print management (desktop mode only)
# =============================================================================

{ config, lib, pkgs, ... }:

let
  cfg = config.device;
in
{
  # ============================================================================
  # CUPS Printing System
  # ============================================================================
  # Enable CUPS (Common Unix Printing System) for comprehensive printing support
  # Only enabled in desktop mode - servers typically don't need printing
  services.printing.enable = lib.mkIf (cfg.mode == "desktop") true;

  # ============================================================================
  # Avahi Network Discovery
  # ============================================================================
  # Configure Avahi for network printer discovery and zero-configuration networking
  # Only enabled in desktop mode - servers typically don't need printer discovery
  services.avahi = lib.mkIf (cfg.mode == "desktop") {
    enable = true;                   # Enable Avahi for network service discovery
    
    # ========================================================================
    # Name Resolution
    # ========================================================================
    # Enable mDNS4 name resolution for network printer discovery
    # This allows automatic detection of network printers and services
    nssmdns4 = true;
    
    # ========================================================================
    # Network Access
    # ========================================================================
    # Open firewall ports for Avahi network discovery
    # This enables network printer discovery and service advertisement
    openFirewall = true;
  };
} 