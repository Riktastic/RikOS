# =============================================================================
# Kernel Configuration Module
# =============================================================================
#
# This module configures the Linux kernel for the system, selecting different
# kernel variants based on device mode (desktop vs server).
#
# What it does:
# - Desktop mode: Zen kernel for reduced latency and improved responsiveness
# - Server mode: Hardened kernel for enhanced security and stability
# - Optimizes for specific workloads (desktop/gaming vs server)
# - Enhances I/O performance and CPU scheduling
# - Provides better power management and real-time application handling
#
# Requirements:
# - Compatible hardware for selected kernel
# - Sufficient system resources for kernel features
# - Device-specific kernel modules configured separately
# - Device mode must be set (desktop or server)
#
# Usage:
# - Imported by main configuration automatically
# - Kernel selection based on device.mode
# - Boot configuration handles kernel module loading
# =============================================================================

# Device-Mode Aware Kernel Module
{ config, pkgs, lib, ... }:

let
  cfg = config.device;
in
{
  # ============================================================================
  # Device-Mode Aware Kernel Selection
  # ============================================================================
  # Select kernel package based on device mode
  # - Desktop: Zen kernel for performance and low latency
  # - Server: Hardened kernel for security and stability
  boot.kernelPackages = if cfg.mode == "server" 
    then pkgs.linuxPackages_hardened  # Hardened kernel for servers
    else pkgs.linuxPackages_zen;      # Zen kernel for desktops

  # ============================================================================
  # Server-Specific Kernel Security
  # ============================================================================
  # Additional security configurations for server mode
  boot.kernelParams = lib.optionals (cfg.mode == "server") [
    # ========================================================================
    # Security Hardening Parameters
    # ========================================================================
    "slab_nomerge"           # Prevent slab merging (security)
    "pti=on"                 # Enable Page Table Isolation
    "vsyscall=none"          # Disable vsyscall (security)
    "debugfs=off"            # Disable debugfs (security)
    "oops=panic"             # Panic on kernel oops
    "panic_on_warn=1"        # Panic on kernel warnings
    "loglevel=0"             # Minimize kernel logging
    "quiet"                  # Reduce boot messages
    "console=ttyS0"          # Use serial console (if available)
  ];

  # ============================================================================
  # Kernel Configuration Extension
  # ============================================================================
  # Ensure the LZ4 crypto compressor is built into the kernel (not a module)
#  boot.kernelPatches = [
#    {
#      name = "enable-lz4-crypto";
#      patch = null;
#      extraConfig = ''
#        CRYPTO_LZ4 y
#      '';
#    }
#  ];
}
