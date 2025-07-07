# =============================================================================
# Secure Boot Configuration Module
# =============================================================================
#
# Configures Lanzaboote for UEFI secure boot support and boot process integrity.
#
# What it does:
# - Enables UEFI secure boot implementation with Lanzaboote
# - Replaces systemd-boot with secure boot-capable alternative
# - Provides bootloader and kernel signature verification
# - Protects against bootkit attacks and unauthorized bootloaders
# - Installs sbctl tool for secure boot management
# - Maintains chain of trust throughout boot process
#
# Requirements:
# - UEFI firmware with secure boot support
# - Compatible hardware and firmware
# - Lanzaboote package and dependencies
#
# Usage:
# - Import in main configuration
# - Lanzaboote replaces systemd-boot automatically
# - Secure boot keys managed automatically
# - Use sbctl for manual management and troubleshooting
# =============================================================================

{pkgs, lib, ... }:

{
  # ============================================================================
  # Secure Boot Management Tools
  # ============================================================================
  # Install sbctl for secure boot management and troubleshooting
  # This tool provides command-line interface for secure boot operations
  environment.systemPackages = with pkgs; [
    # ========================================================================
    # Secure Boot Management Tool
    # ========================================================================
    # sbctl provides debugging and troubleshooting capabilities for Secure Boot
    # It allows manual management of secure boot keys and signatures
    sbctl
  ];

  # ============================================================================
  # Bootloader Configuration
  # ============================================================================
  # Disable systemd-boot as Lanzaboote replaces it
  # This prevents conflicts between the two bootloaders
  boot.loader.systemd-boot.enable = lib.mkForce false;

  # ============================================================================
  # Lanzaboote Configuration
  # ============================================================================
  # Configure Lanzaboote for secure boot implementation
  boot.lanzaboote = {
    # ========================================================================
    # Enable Lanzaboote
    # ========================================================================
    # Enable Lanzaboote secure boot implementation
    # This replaces systemd-boot with a secure boot-capable alternative
    enable = true;
    
    # ========================================================================
    # PKI Bundle Location
    # ========================================================================
    # Specify the location for secure boot keys and certificates
    # This directory contains the PKI bundle for secure boot operations
    pkiBundle = "/var/lib/sbctl";
  };
}
