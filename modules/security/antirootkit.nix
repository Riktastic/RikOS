# =============================================================================
# Antirootkit Configuration Module
# =============================================================================
#
# Configures chkrootkit for rootkit detection and monitoring.
#
# What it does:
# - Installs chkrootkit for scanning known rootkits and backdoors
# - Detects suspicious system modifications and hidden processes
# - Schedules daily automated scans via systemd timer
# - Logs results to system journal
#
# Requirements:
# - chkrootkit package
# - Systemd for timer and service management
# - Sufficient permissions for system scanning
#
# Usage:
# - Import in main configuration
# - Daily scans run automatically via systemd
# - Run manual scans with chkrootkit command
# - View results in system journal
# =============================================================================

{ config, pkgs, ... }:

{
  # ============================================================================
  # Module Options
  # ============================================================================
  # Define module-specific options (currently empty)
  options = {};

  # ============================================================================
  # Module Configuration
  # ============================================================================
  # Configure chkrootkit and automated scanning
  config = {
    # ========================================================================
    # Package Installation
    # ========================================================================
    # Install chkrootkit package for rootkit detection
    # This provides the core scanning functionality
    environment.systemPackages = with pkgs; [
      chkrootkit  # Rootkit detection and scanning tool
    ];

    # ========================================================================
    # Automated Scanning Service
    # ========================================================================
    # Systemd service for automated chkrootkit scanning
    # Runs as a oneshot service triggered by timer
    systemd.services.chkrootkit-scan = {
      # ================================================================
      # Service Description
      # ================================================================
      description = "Daily chkrootkit scan";
      
      # ================================================================
      # Service Configuration
      # ================================================================
      serviceConfig = {
        Type = "oneshot";  # Run once and exit
        ExecStart = "${pkgs.chkrootkit}/bin/chkrootkit";  # Execute chkrootkit scan
      };
    };

    # ========================================================================
    # Automated Scanning Timer
    # ========================================================================
    # Systemd timer to trigger daily chkrootkit scans
    # Ensures regular system integrity monitoring
    systemd.timers.chkrootkit-scan = {
      # ================================================================
      # Timer Description
      # ================================================================
      description = "Daily chkrootkit scan timer";
      
      # ================================================================
      # Timer Configuration
      # ================================================================
      wantedBy = [ "timers.target" ];  # Enable timer on boot
      timerConfig = {
        OnCalendar = "daily";  # Run once per day
        Persistent = true;     # Run missed scans on boot
      };
    };
  };
}
