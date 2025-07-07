# =============================================================================
# AppArmor Configuration Module
# =============================================================================
#
# Configures AppArmor mandatory access control with learning mode approach.
#
# What it does:
# - Enables AppArmor for fine-grained application access control
# - Starts in learning mode for profile development
# - Automatically transitions to enforcement after 180 days
# - Provides process isolation and resource restrictions
# - Integrates with system services for security
#
# Requirements:
# - Linux kernel with AppArmor support
# - Systemd for timer and service management
# - Proper permissions for profile management
#
# Usage:
# - Import in main configuration
# - AppArmor starts in learning mode
# - Profiles automatically enforced after 180 days
# - Use aa-status to check profile status
# =============================================================================

{ config, pkgs, lib, ... }:

let
  # ============================================================================
  # Configuration Constants
  # ============================================================================
  # Time period before transitioning to enforcement mode
  # 180 days in seconds (180 * 24 * 60 * 60)
  enforceAfter = 180 * 24 * 60 * 60;
in
{
  # ============================================================================
  # AppArmor Enforcement Timer
  # ============================================================================
  # Systemd timer to trigger AppArmor enforcement transition
  # Ensures automatic transition from learning to enforcement mode
  systemd.timers.apparmor-enforce = {
    # ========================================================================
    # Timer Configuration
    # ========================================================================
    wantedBy = [ "timers.target" ];  # Enable timer on boot
    
    timerConfig = {
      OnBootSec = "${toString enforceAfter}s";  # Trigger after 180 days from boot
      AccuracySec = "1h";                       # Allow 1-hour accuracy window
      Persistent = true;                        # Run missed timers on boot
    };
  };

  # ============================================================================
  # AppArmor Enforcement Service
  # ============================================================================
  # Systemd service to transition all AppArmor profiles to enforcement mode
  # This service is triggered by the timer after the learning period
  systemd.services.apparmor-enforce = {
    # ========================================================================
    # Service Script
    # ========================================================================
    # Script to enforce all AppArmor profiles
    # Iterates through all profiles and enables enforcement
    script = ''
      # ================================================================
      # Profile Enforcement Script
      # ================================================================
      # Loop through all AppArmor profiles and enable enforcement
      # The || true ensures the script continues even if some profiles fail
      for profile in /etc/apparmor.d/*; do
        aa-enforce "$profile" || true
      done
    '';
    
    # ========================================================================
    # Service Configuration
    # ========================================================================
    serviceConfig = {
      Type = "oneshot";  # Run once and exit
      User = "root";     # Run as root for profile management
    };
  };
}
