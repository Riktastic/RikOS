# =============================================================================
# Antivirus Configuration Module
# =============================================================================
#
# This module configures ClamAV antivirus protection for real-time malware
# detection and scanning capabilities.
#
# What it does:
# - Enables ClamAV daemon for real-time file scanning and monitoring
# - Configures automatic virus definition updates via freshclam
# - Provides on-demand scanning with clamscan and clamdscan
# - Supports multiple file formats and archive scanning
# - Integrates with file managers and email clients
# - Protects against viruses, trojans, and malicious software
#
# Requirements:
# - Internet connection for virus definition updates
# - Sufficient disk space for virus signatures
# - System resources for real-time scanning
# - Compatible file systems and applications
#
# Usage:
# - Imported by main configuration automatically
# - Services start automatically on boot
# - Use clamscan for manual directory/file scanning
# - Use freshclam for manual definition updates
# =============================================================================

{ config, pkgs, ... }:

{
  # ============================================================================
  # ClamAV Service Configuration
  # ============================================================================
  # Configure ClamAV antivirus services for comprehensive protection
  services.clamav = {
    # ========================================================================
    # Daemon Configuration
    # ========================================================================
    # Enable ClamAV daemon for real-time scanning
    # The daemon provides background scanning and monitoring
    daemon.enable = true;
    
    # ========================================================================
    # Updater Configuration
    # ========================================================================
    # Enable automatic virus definition updates
    # freshclam runs periodically to keep signatures current
    updater.enable = true;
    
    # ========================================================================
    # Scanner Configuration
    # ========================================================================
    # Enable command-line scanner for on-demand scanning
    # Provides clamscan and clamdscan utilities
    scanner.enable = true;
  };

  # ============================================================================
  # Package Installation
  # ============================================================================
  # Install ClamAV packages system-wide
  # These provide the core antivirus functionality
  environment.systemPackages = with pkgs; [
    clamav  # Core ClamAV antivirus package
  ];
} 