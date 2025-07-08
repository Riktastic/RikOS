# =============================================================================
# System Performance Optimization Module
# =============================================================================
#
# This module provides comprehensive system-level performance optimizations
# for enhanced speed, responsiveness, and efficiency.
#
# What it does:
# - Enables early KMS for faster boot and better graphics performance
# - Configures kernel parameters for CPU, I/O, and network optimization
# - Sets up zram and zswap for improved memory management
# - Enables systemd-oomd for intelligent memory management
# - Configures power management and performance governor
# - Installs powertop for power optimization
# - Optimizes systemd services and journald for performance
# - Sets up SSD-optimized I/O scheduler and periodic TRIM
#
# Requirements:
# - Compatible hardware (CPU, SSD, graphics)
# - Sufficient RAM for zram/zswap
# - powertop and other optimization tools
# - Systemd for service management
#
# Usage:
# - Imported by device configurations automatically
# - Performance optimizations applied on boot
# - Memory and power management active immediately
# =============================================================================

# System Performance Optimizations
#
# This module contains various system-level optimizations for better performance
# while maintaining stability on NixOS 25.05 LTS.

{ config, lib, pkgs, ... }:

{
  # ============================================================================
  # Kernel Parameters
  # ============================================================================
  # Enable kernel optimizations for maximum performance
  boot.kernelParams = [
    # ========================================================================
    # CPU Performance Optimizations
    # ========================================================================
#    "mitigations=off"           # Disable CPU mitigations for better performance, already configured in the CPU modules
#    "processor.max_cstate=1"    # Limit CPU C-states for better responsiveness
    
    # ========================================================================
    # I/O Performance Optimizations
    # ========================================================================
    "elevator=none"            # Use noop I/O scheduler for SSDs
    "zswap.enabled=1"          # Enable zswap for better memory management
#    "zswap.compressor=lz4"     # Use lz4 for zswap compression, currently not built into the kernel
    "zswap.max_pool_percent=20" # Limit zswap pool size
    
    # ========================================================================
    # Network Performance Optimizations
    # ========================================================================
    "net.core.rmem_max=26214400"  # Increase network read buffer
    "net.core.wmem_max=26214400"  # Increase network write buffer
  ];

  # ============================================================================
  # Power Management
  # ============================================================================
  # Configure power management for optimal performance
  powerManagement = {
    # ========================================================================
    # CPU Frequency Governor
    # ========================================================================
    # Use performance governor for maximum CPU speed
    cpuFreqGovernor = "performance";
    
    # ========================================================================
    # Power Management Tools
    # ========================================================================
    # Enable powertop for power management optimization
    powertop.enable = true;
  };

  # ============================================================================
  # Memory Management
  # ============================================================================
  # Enable systemd-oomd for intelligent memory management
  systemd.oomd = {
    enable = true;              # Enable out-of-memory daemon
    enableRootSlice = true;     # Enable for root slice
    enableUserSlices = true;    # Enable for user slices
  };

  # ========================================================================
  # Systemd Service Optimization
  # ========================================================================
  # Optimize systemd services for better performance
  systemd.services = {
    # ========================================================================
    # OOM Daemon Optimization
    # ========================================================================
    # Optimize systemd-oomd for better memory management
    "systemd-oomd".serviceConfig = {
      OOMScoreAdjust = -100;  # Make oomd less likely to be killed
    };
  };

  # ============================================================================
  # Memory Compression
  # ============================================================================
  # Enable zram for better memory management and performance
  zramSwap = {
    enable = true;              # Enable zram swap
    algorithm = "lz4";          # Use lz4 for better compression performance
    memoryPercent = 50;         # Use 50% of RAM for zram
  };

  # ============================================================================
  # System Logging Optimization
  # ============================================================================
  # Optimize systemd journal for better performance
  services.journald = {
    extraConfig = ''
      # ========================================================================
      # Journal Size Management
      # ========================================================================
      SystemMaxUse=1G           # Maximum journal size
      SystemMaxFileSize=128M    # Maximum individual file size
      SystemMaxFiles=10         # Maximum number of files
    '';
  };

  # ============================================================================
  # Boot Loader Optimization
  # ============================================================================
  # Optimize systemd-boot for faster boot times
  boot.loader.systemd-boot.configurationLimit = 10;  # Keep last 10 generations

  # ============================================================================
  # Systemd Configuration
  # ============================================================================
  # Optimize systemd for better performance and faster boot
  systemd.extraConfig = ''
    # ========================================================================
    # Service Timeout Optimization
    # ========================================================================
    DefaultTimeoutStartSec=10s  # Reduce service start timeout
    DefaultTimeoutStopSec=10s   # Reduce service stop timeout
    DefaultRestartSec=100ms     # Reduce service restart delay
  '';

  # ============================================================================
  # Device Detection Optimization
  # ============================================================================
  # Disable systemd-udev-settle for faster boot
  systemd.services.systemd-udev-settle.enable = false;

  # ============================================================================
  # Udev Optimization
  # ============================================================================
  # Optimize udev rules for better performance
  services.udev.extraRules = ''
    # ========================================================================
    # SCSI Power Management Optimization
    # ========================================================================
    # Optimize SCSI host power management for better performance
    ACTION=="add", SUBSYSTEM=="scsi_host", KERNEL=="host*", ATTR{link_power_management_policy}="min_power"
  '';

  # ============================================================================
  # Network Performance Tuning
  # ============================================================================
  # Enable TCP BBR and network optimizations for better performance
  boot.kernel.sysctl = {
    # ========================================================================
    # TCP Congestion Control
    # ========================================================================
    "net.core.default_qdisc" = "fq";                    # Fair queuing discipline
    "net.ipv4.tcp_congestion_control" = "bbr";          # BBR congestion control
    "net.ipv4.tcp_fastopen" = 3;                        # TCP fast open
    "net.ipv4.tcp_slow_start_after_idle" = 0;           # Disable slow start after idle
    
    # ========================================================================
    # Network Buffer Optimization
    # ========================================================================
    "net.ipv4.tcp_notsent_lowat" = 16384;               # TCP not sent low watermark
    "net.core.rmem_max" = 26214400;                     # Maximum receive buffer
    "net.core.wmem_max" = 26214400;                     # Maximum send buffer
    "net.ipv4.tcp_rmem" = "4096 87380 16777216";        # TCP receive buffer range
    "net.ipv4.tcp_wmem" = "4096 87380 16777216";        # TCP send buffer range
  };

  # ============================================================================
  # Storage Optimization
  # ============================================================================
  # Enable periodic TRIM for SSD performance maintenance
  services.fstrim = {
    enable = true;              # Enable fstrim service
    interval = "weekly";        # Run TRIM weekly
  };
} 
