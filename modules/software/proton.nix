# =============================================================================
# Proton Software Integration Module
# =============================================================================
#
# This module provides comprehensive integration with the Proton ecosystem
# of privacy-focused applications and services for enhanced privacy and security.
# Supports both desktop (GUI + CLI) and server (CLI only) modes.
#
# What it does:
# - Installs Proton VPN CLI and GUI for encrypted internet access
# - Provides Proton Mail Bridge for secure email integration
# - Includes Rclone for Proton Drive encrypted cloud storage
# - Supports Proton Pass for secure password management
# - Offers privacy-focused applications with end-to-end encryption
# - Provides Swiss-based privacy protection and zero-knowledge architecture
#
# Requirements:
# - Proton account for authentication
# - Internet connection for VPN and cloud services
# - Compatible email clients for Proton Mail Bridge
# - Sufficient storage for cloud synchronization
# - Desktop mode for GUI applications
#
# Usage:
# - Imported by device configurations automatically
# - Applications available system-wide for all users
# - Complete authentication setup required per user
# - Use rclone config to set up Proton Drive
# =============================================================================

# modules/global/proton.nix
# Global Proton (Proton Drive, Proton Pass, Proton Mail, Proton VPN) module.
# This module globally adds Proton Drive, Proton Pass, Proton Mail, and Proton VPN (via protonvpn-cli) so that all users (including rik) can use them.

{ config, pkgs, lib, ... }:

let
  cfg = config.device;
in

{
  # ============================================================================
  # Proton Software Installation
  # ============================================================================
  # Install Proton ecosystem applications system-wide for all users
  environment.systemPackages = with pkgs; [
    # ========================================================================
    # Core Proton Tools (Both modes)
    # ========================================================================
    # Proton VPN CLI for command-line VPN management
    # Provides secure VPN connections with privacy protection
    protonvpn-cli

    # ========================================================================
    # Proton Drive Integration
    # ========================================================================
    # Rclone for Proton Drive cloud storage integration
    # Provides command-line access to encrypted cloud storage
    rclone
  ] ++ lib.optionals (cfg.mode == "desktop") [
    # ========================================================================
    # Desktop-specific Proton Tools
    # ========================================================================
    # Proton VPN GUI for graphical interface
    # User-friendly VPN client with server selection and settings
    protonvpn-gui

    # Proton Mail Bridge for desktop email client integration
    # Enables secure email access through desktop email clients
    protonmail-bridge

    # Proton Mail Desktop application (community package)
    # May not be available in all NixOS versions
    protonmail-desktop

    # Proton Pass password manager (may not be available)
    # Secure password management with end-to-end encryption
    proton-pass
  ] ++ lib.optionals (cfg.mode == "server") [
    # ========================================================================
    # Server-specific Proton Tools
    # ========================================================================
    # Additional CLI tools for server Proton integration
    # (Currently no additional server-specific tools)
  ];

  # ============================================================================
  # Rclone Configuration Template
  # ============================================================================
  # Provide a template for Proton Drive configuration in /etc/rclone.conf
  # Users must run `rclone config` to complete authentication setup
  environment.etc."rclone.conf".text = ''
    # ========================================================================
    # Proton Drive Remote Configuration Template
    # ========================================================================
    # Example Proton Drive remote configuration
    # This template provides the basic structure for Proton Drive integration
    [proton]
    type = protondrive
    # ========================================================================
    # Authentication Setup Required
    # ========================================================================
    # IMPORTANT: You must run `rclone config` as your user to complete
    # authentication and finish the Proton Drive setup process!
    # 
    # Steps to complete setup:
    # 1. Run: rclone config
    # 2. Select "n" for new remote
    # 3. Choose "proton" as the name
    # 4. Select "protondrive" as the storage type
    # 5. Follow the authentication prompts
    # 6. Test the connection with: rclone lsd proton:
  '';
}
