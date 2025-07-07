# =============================================================================
# Default Home Manager Services Module
# =============================================================================
#
# Configures essential background services for user sessions.
#
# What it does:
# - Enables GPG agent with SSH support
# - Enables KDE Connect for mobile device integration
#
# Requirements:
# - KDE Plasma desktop for KDE Connect
# - GPG keys for authentication
#
# Usage:
# - Import in user home-manager configurations
# - Services start automatically on login
# =============================================================================

{ config, pkgs, lib, ... }:

{
  # ============================================================================
  # Background Services Configuration
  # ============================================================================
  services = {
    # ========================================================================
    # GPG Agent Service
    # ========================================================================
    # Enable GPG agent for secure key management
    # This provides secure storage and caching of GPG keys
    gpg-agent = {
      enable = true;                    # Enable GPG agent service
      enableSshSupport = true;          # Enable SSH key integration
      pinentry.package = pkgs.pinentry-qt;  # Use Qt-based pinentry for KDE
    };

    # ========================================================================
    # KDE Connect Service
    # ========================================================================
    # Enable KDE Connect for mobile device integration
    # This provides seamless integration with Android/iOS devices
    kdeconnect = {
      enable = true;        # Enable KDE Connect service
      indicator = true;     # Show system tray indicator
    };
  };
} 
