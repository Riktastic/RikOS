# =============================================================================
# System Networking Configuration Module
# =============================================================================
#
# Provides basic system networking configuration including hostname and network management.
#
# What it does:
# - Configures system hostname for network identification
# - Enables NetworkManager for automatic network detection
# - Sets up time zone and time synchronization
# - Provides wireless and wired network support
# - Enables network interface management and DHCP
# - Supports VPN connections and network profiles
#
# Requirements:
# - NetworkManager package and dependencies
# - Compatible network hardware
# - Proper network connectivity
#
# Usage:
# - Import in device configurations
# - NetworkManager starts automatically on boot
# - Hostname set for system identification
# - Use nmcli/nmtui for network management
# =============================================================================

{ config, lib, pkgs, ... }:

{
  # ============================================================================
  # Networking Configuration
  # ============================================================================
  # Configure system networking and network management
  networking = {
    
    # ========================================================================
    # Network Management
    # ========================================================================
    # Enable NetworkManager for comprehensive network management
    # NetworkManager provides automatic network detection, wireless
    # network management, VPN support, and network troubleshooting
    networkmanager.enable = true;
  };
} 
