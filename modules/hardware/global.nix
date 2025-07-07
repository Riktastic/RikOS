# =============================================================================
# Global Hardware Configuration Module
# =============================================================================
#
# Provides global hardware settings and firmware update services for all devices.
#
# What it does:
# - Enables fwupd daemon for automatic firmware updates
# - Supports UEFI, BIOS, and device firmware updates
# - Provides secure firmware update process with verification
# - Integrates with desktop software centers
#
# Requirements:
# - Hardware with updatable firmware
# - UEFI/BIOS, graphics cards, storage devices, network cards
# - Internet connection for firmware downloads
#
# Usage:
# - Imported by main configuration automatically
# - Use fwupdmgr for manual firmware management
# - Updates available through system tools
# =============================================================================

{ config, pkgs, ... }:

{
  # ============================================================================
  # Firmware Update Service
  # ============================================================================
  # Enable fwupd daemon for automatic firmware updates
  # This service manages firmware updates for supported hardware
  services.fwupd.enable = true;

  environment.systemPackages = with pkgs; [
    libusb1           # For SDRs and other USB devices
  ];
} 
