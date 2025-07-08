# =============================================================================
# System Boot Configuration Module
# =============================================================================
#
# This module configures the system boot process, bootloader, and boot-time
# optimizations for a clean, fast, and secure boot experience.
#
# What it does:
# - Configures UEFI systemd-boot loader with EFI variable access
# - Enables Plymouth graphical boot splash with spinfinity theme
# - Reduces boot verbosity for cleaner startup experience
# - Sets up systemd integration in initrd for better boot process
# - Configures kernel parameters for quiet boot and splash support
# - Optimizes video mode for EFI framebuffer (2560x1080)
# - Enables secure boot compatibility and boot entry management
# - Provides fast boot capabilities with reduced logging
#
# Requirements:
# - UEFI-compatible system
# - EFI partition mounted at /boot/efi
# - Compatible graphics hardware
# - Sufficient system resources for Plymouth
#
# Usage:
# - Imported by device configurations automatically
# - Bootloader configured automatically on system build
# - Plymouth starts on boot for graphical interface
# - Boot process optimized for speed and cleanliness
# =============================================================================

{ config, lib, pkgs, ... }:

let
  cfg = config.device;
in
{
  # ============================================================================
  # Boot Configuration
  # ============================================================================
  # Configure system boot process, bootloader, and boot-time optimizations
  boot = {
    # ========================================================================
    # Bootloader Configuration
    # ========================================================================
    # Configure UEFI bootloader for secure and fast boot
    loader = {
      # ================================================================
      # Systemd-Boot Configuration
      # ================================================================
      # Enable systemd-boot for UEFI systems
      # systemd-boot provides a simple, secure bootloader for UEFI
      systemd-boot.enable = true;

      # ================================================================
      # EFI Configuration
      # ================================================================
      # Allow systemd-boot to modify EFI variables
      # This enables boot entry management and secure boot configuration
      efi.canTouchEfiVariables = true;

      timeout = 0; # Hide the OS choice by default. It is still possible to open the bootlaoder list by pressing any key.
    };

    # ========================================================================
    # Boot Process Optimization
    # ========================================================================
    # Reduce boot verbosity for a cleaner, more professional boot experience
    consoleLogLevel = 3;              # Reduce console logging level

    # ================================================================
    # Initrd Configuration
    # ================================================================
    # Configure initial ramdisk for faster and cleaner boot
    initrd.verbose = false;           # Reduce initrd verbosity
    initrd.systemd.enable = true;     # Enable systemd in initrd for better integration

    # ========================================================================
    # Kernel Parameters
    # ========================================================================
    # Configure kernel parameters for optimal boot experience
    kernelParams = lib.mkIf (cfg.mode == "desktop") [
      # ============================================================
      # Boot Experience Parameters
      # ============================================================
      "quiet"                         # Reduce kernel output for clean boot
      "splash"                        # Enable splash screen support
      "boot.shell_on_fail"            # Show the error when the system fails to boot

      # ============================================================
      # Systemd and Udev Parameters
      # ============================================================
      "udev.log_priority=3"           # Reduce udev logging verbosity
      "rd.systemd.show_status=auto"   # Auto-hide systemd status during boot

      # ============================================================
      # Display Configuration
      # ============================================================
      # Set video mode for EFI framebuffer
      # This ensures proper display resolution during boot
      "video=efifb:2560x1080"
    ];

    # ========================================================================
    # Plymouth Configuration
    # ========================================================================
    # Enable Plymouth for graphical boot splash and disk unlock
    plymouth = lib.mkIf (cfg.mode == "desktop") {
      enable = true;                  # Enable Plymouth graphical boot

      # ============================================================
      # Plymouth Theme
      # ============================================================
      # Use spinfinity theme for modern, animated boot splash
      # This provides a professional boot experience with animations
      theme = "spinfinity";
    };
  };
}
